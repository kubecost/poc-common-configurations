# Overview
These are the steps to enable ETL federation with Kubecost on Red Hat OpenShift on AWS (ROSA) cluster.

Using aws with IAM roles attached to service accounts:

Federated-ETL is an efficient method to implement multi-cluster Kubecost while using existing Prometheus installations for short-term metrics.

> Note: Kubecost can rebuild its data (ETLs) using the Prometheus metrics from each cluster. It is recommended to retain local cluster Prometheus metrics that meet an organization's disaster recovery requirements.

The example in this directory uses the Kubecost Prometheus server.

[Contact us](https://www.kubecost.com/contact) for help customizing settings.

## Prerequisites:

1. You have [Red Hat OpenShift Service on AWS cluster (ROSA) set up with AWS Security Token Service (STS)](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa-sts-creating-a-cluster-quickly.html#rosa-sts-creating-a-cluster-quickly-cli_rosa-sts-creating-a-cluster-quickly).
2. You have approriate IAM permissions to manage ROSA cluster and manage,create and assign AWS IAM.
3. The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [rosa](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-installing-rosa.html), and [oc CLI](https://docs.openshift.com/container-platform/4.10/cli_reference/openshift_cli/getting-started-cli.html)
4. Clone this repository into your machine and navigate to `POC-COMMON-CONFIGURATION-TEST/etl-federation`

## Instructions:

### Prerequisites:
- Set up necessary ENV variables:

```
export KC_BUCKET="kubecost-etl-metrics"
export ROSA_CLUSTER_NAME=YOUR_ROSA_CLUSTER_NAME
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export APP_NAMESPACE=kubecost
```

### Step 1: Create Object store S3 bucket to store Kubecost ETL metrics:

`aws s3 mb s3://${KC_BUCKET}`

- If your 2nd cluster is running on different AWS account, you need to set appropriate permission and IAM policy to allow Kubecost putting data on a central S3 bucket located on primary account. There are 2 ways to do that:

    * **S3 bucket policy:** Set up S3 bucket policy to grant access to other AWS accounts.
    * **Cross AWS accounts IAM roles:** Set up an IAM role with permission to access to the central S3 bucket and trusted policy to allow other AWS accounts to assume that IAM role to have access to the central S3 bucket.

- You can read more on how to do it in official AWS documentation [here](https://aws.amazon.com/premiumsupport/knowledge-center/cross-account-access-s3/)

- For POC deployment and standard set up, we recommend to use **S3 bucket policy** option. However, you can use **Cross AWS accounts IAM roles** if you need more advanced set-up to comply with your organization policy.
- Examples:

    * This is an example of S3 bucket policy that grant access to additional AWS accounts:

```Json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::<ReplacewithAccountBID>:root",
                    "arn:aws:iam::<ReplacewithAccountCID>:root",
                    "arn:aws:iam::<ReplacewithAccountDID>:root"
                ]
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::kubecost-etl-metrics/*",
                "arn:aws:s3:::kubecost-etl-metrics"
            ]
        }
    ]
}
```

   * This is an example of IAM policy you need to add on non-primary AWS accounts to have access to the central S3 bucket:


```Json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::kubecost-etl-metrics/*",
                "arn:aws:s3:::kubecost-etl-metrics"
            ]
        }
    ]
}
```

### Step 2: Update configuration
- Update [policy-kubecost-aws-s3.json](policy-kubecost-aws-s3.json) and [federated-store.yaml](federated-store.yaml) and [primary-federator.yaml](primary-federator.yaml) with your bucket name.

```bash
# This command is for MAC OS. Remove ''
sed -i '' "s/kubecost-UNIQUE_NAME-metrics/${KC_BUCKET}/g" policy-kubecost-aws-s3.json
sed -i '' "s/kubecost-UNIQUE_NAME-metrics/${KC_BUCKET}/g" federated-store.yaml
```
### Step 3: Run the following commands to create appropriate policy and the secret for the object-store for kubecost federation:

```bash
aws iam create-policy \
 --policy-name kubecost-s3-federated-policy \
 --policy-document file://policy-kubecost-aws-s3.json
```

```bash
kubectl create ns $APP_NAMESPACE
kubectl create secret generic \
  kubecost-object-store -n $APP_NAMESPACE \
  --from-file federated-store.yaml
```

### Step 4: Get the OIDC endpoint URL of the cluster:

```bash
export OIDC_PROVIDER=$(oc get authentication.config.openshift.io cluster -ojson | jq -r .spec.serviceAccountIssuer | sed 's/https:\/\///')
```
### Step 5: Create required service accounts.

```bash
oc create serviceaccount kubecost-irsa-s3 -n $APP_NAMESPACE
```
### Step 6: Create the IAM roles for the service accounts.

```bash
cat <<EOF > ./IAM-trust-relationship-kubecost-irsa-s3.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:${APP_NAMESPACE}:kubecost-irsa-s3"
        }
      }
    }
  ]
}
EOF
```

```bash
export APP_IAM_ROLE_KUBECOST_IRSA_S3="iam-kubecost-kubecost-irsa-s3-role"
export APP_IAM_ROLE_ROLE_DESCRIPTION_KUBECOST_IRSA_S3="IRSA role for kubecost etl-federation"
aws iam create-role --role-name "${APP_IAM_ROLE_KUBECOST_IRSA_S3}" --assume-role-policy-document file://IAM-trust-relationship-kubecost-irsa-s3.json --description "${APP_IAM_ROLE_ROLE_DESCRIPTION_KUBECOST_IRSA_S3}"
APP_IAM_ROLE_ARN_KUBECOST_IRSA_S3=$(aws iam get-role --role-name=$APP_IAM_ROLE_KUBECOST_IRSA_S3 --query Role.Arn --output text)
```
### Step 7: Attach IAM policies to the IAM roles 

```bash
aws iam attach-role-policy --role-name "${APP_IAM_ROLE_KUBECOST_IRSA_S3}" \
--policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/kubecost-s3-federated-policy"
```

```bash
export IRSA_ROLE_ARN_KUBECOST_IRSA_S3="eks.amazonaws.com/role-arn=${APP_IAM_ROLE_ARN_KUBECOST_IRSA_S3}"
oc annotate serviceaccount -n $APP_NAMESPACE kubecost-irsa-s3 $IRSA_ROLE_ARN_KUBECOST_IRSA_S3
```

### Step 8: Install Kubecost Primary Instance:

#### Primary Cluster

```bash
helm upgrade -i kubecost \
  --repo https://raw.githubusercontent.com/kubecost/openshift-helm-chart/main/ cost-analyzer \
  --namespace ${APP_NAMESPACE} \
  -f https://raw.githubusercontent.com/kubecost/openshift-helm-chart/main/values-openshift.yaml \
  -f primary-federator.yaml \
  --set prometheus.server.global.external_labels.cluster_id=$ROSA_CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=$ROSA_CLUSTER_NAME \
  --set federatedETL.federator.primaryClusterID=$ROSA_CLUSTER_NAME
```
#### Install Agents on all other clusters
Repeat from the `Step 2` above for all clusters, using the same S3 bucket.

Be sure to either set the `CLUSTER_NAME` here or in both locations of the [agent-federated.yaml](agent-federated.yaml).

> Note: in the below install command, because the CLUSTER_NAME arguments come after the filename, the arguments will win.

```bash
export CLUSTER_NAME=cluster2
helm install kubecost2 \
  --repo https://raw.githubusercontent.com/kubecost/openshift-helm-chart/main/ cost-analyzer \
  --namespace ${APP_NAMESPACE} \
  -f https://raw.githubusercontent.com/kubecost/openshift-helm-chart/main/values-openshift.yaml \
  -f agent-federated-copy.yaml \
  --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=$CLUSTER_NAME
```
