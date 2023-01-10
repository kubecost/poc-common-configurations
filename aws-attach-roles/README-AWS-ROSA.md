This is still a work in progress, meant as an example method for attached an IAM role to the service account used by Kubecost.

Using aws with IAM roles attached to service accounts:

## Prerequisites:

1. You have [Red Hat OpenShift Service on AWS cluster (ROSA) set up with AWS Security Token Service (STS](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa-sts-creating-a-cluster-quickly.html#rosa-sts-creating-a-cluster-quickly-cli_rosa-sts-creating-a-cluster-quickly).
2. You have approriate IAM permissions to manage ROSA cluster and manage,create and assign AWS IAM.
3. The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [rosa](https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-installing-rosa.html), and [oc CLI](https://docs.openshift.com/container-platform/4.10/cli_reference/openshift_cli/getting-started-cli.html)
4. Clone this repository into your machine and navigate to POC-COMMON-CONFIGURATION-TEST/aws-attach-roles
5. Remember to update cloud-integration.jon with approriate information of your Athena set up for Cost Usage Report (CUR). For more information, please refer to this [documentation](https://guide.kubecost.com/hc/en-us/articles/4407595928087-AWS-Cloud-Integration)

## Instructions:

### Prerequisites:
- Set up necessary ENV variables:

```
export ThanosBucketName="<your-object-store-bucket-name>"
export ROSA_CLUSTER_NAME=<cluster-name>
export AWS_REGION=<aws-region-id>
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export APP_NAMESPACE=kubecost
```

### Step 1: Create Object store S3 bucket to store Thanos data:

`aws s3 mb s3://${ThanosBucketName} --region `

- If your 2nd cluster is running on different AWS account, you need to set appropriate permission and IAM policy to allow Thanos sidecar put data on a central S3 bucket located on primary account. There are 2 ways to do that:

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
                "arn:aws:s3:::<ThanosBucketName>/*",
                "arn:aws:s3:::<ThanosBucketName>"
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
                "arn:aws:s3:::<ThanosBucketName>/*",
                "arn:aws:s3:::<ThanosBucketName>"
            ]
        }
    ]
}
```

### Step 2: Update configuration
- Update configuration of these files: cloud-integration.json, kubecost-athena-policy.json, kubecost-s3-thanos-policy.json, object-store.yaml, productkey.json (optional if it is only for evaluation) accordingly with your information. The values that need to be updated is in <....>

NOTE: In the cloud-integration.json file, the <AWS_cloud_integration_athenaBucketName> is the "arn:aws:s3:::aws-athena-query-results-*" bucket.

### Step 3: Run the following commands to create appropriate policy:

```sh
cd poc-common-configuration/aws-attach-roles
aws iam create-policy --policy-name kubecost-athena-policy --policy-document file://kubecost-athena-policy.json
aws iam create-policy --policy-name kubecost-s3-thanos-policy --policy-document file://kubecost-s3-thanos-policy.json
```

### Step 4: Get the OIDC endpoint URL of the cluster:

```bash
export OIDC_PROVIDER=$(oc get authentication.config.openshift.io cluster -ojson | jq -r .spec.serviceAccountIssuer | sed 's/https:\/\///')
```
### Step 5: Create required service accounts.

```bash
# Create Kubecost namespace/project
oc create new-project $APP_NAMESPACE
```

```bash
oc create serviceaccount kubecost-serviceaccount-cur-athena-thanos -n $APP_NAMESPACE
oc create serviceaccount kubecost-serviceaccount-thanos -n $APP_NAMESPACE
```
### Step 6: Create the IAM roles for the service accounts.

```bash
$ cat <<EOF > ./IAM-trust-relationship-cur-athena-thanos.json
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
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:${APP_NAMESPACE}:kubecost-serviceaccount-cur-athena-thanos"
        }
      }
    }
  ]
}
EOF
```

```bash
$ cat <<EOF > ./IAM-trust-relationship-thanos.json
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
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:${APP_NAMESPACE}:kubecost-serviceaccount-thanos"
        }
      }
    }
  ]
}
EOF
```

```bash
$ export APP_IAM_ROLE_CUR_ATHENA_THANOS="iam-kubecost-cur-athena-thanos-role"
$ export APP_IAM_ROLE_ROLE_DESCRIPTION_CUR_ATHENA_THANOS='IRSA role for kubecost aws cloud integration on ROSA cluster'
$ aws iam create-role --role-name "${APP_IAM_ROLE_CUR_ATHENA_THANOS}" --assume-role-policy-document file://IAM-trust-relationship-cur-athena-thanos.json --description "${APP_IAM_ROLE_ROLE_DESCRIPTION_CUR_ATHENA_THANOS}"
$ APP_IAM_ROLE_ARN_CUR_ATHENA_THANOS=$(aws iam get-role --role-name=$APP_IAM_ROLE_CUR_ATHENA_THANOS --query Role.Arn --output text)
```

```bash
$ export APP_IAM_ROLE_THANOS="iam-kubecost-thanos-role"
$ export APP_IAM_ROLE_ROLE_DESCRIPTION_THANOS='IRSA role for kubecost - Thanos deployment on ROSA cluster'
$ aws iam create-role --role-name "${APP_IAM_ROLE_THANOS}" --assume-role-policy-document file://IAM-trust-relationship-thanos.json --description "${APP_IAM_ROLE_ROLE_DESCRIPTION_THANOS}"
$ APP_IAM_ROLE_ARN_THANOS=$(aws iam get-role --role-name=$APP_IAM_ROLE_THANOS --query Role.Arn --output text)
```
### Step 7: Attach IAM policies to the IAM roles 

```bash
aws iam attach-role-policy --role-name "${APP_IAM_ROLE_CUR_ATHENA_THANOS}" \
--policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/kubecost-athena-policy" \
aws iam attach-role-policy --role-name "${APP_IAM_ROLE_CUR_ATHENA_THANOS}" \
--policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/kubecost-s3-thanos-policy"
```

```bash
aws iam attach-role-policy --role-name "${APP_IAM_ROLE_THANOS}" \
--policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/kubecost-s3-thanos-policy"
```

### Step 8: Associate the IAM roles to the service accounts:

```bash
export IRSA_ROLE_ARN_CUR_ATHENA_THANOS=eks.amazonaws.com/role-arn=$APP_IAM_ROLE_ARN_CUR_ATHENA_THANOS
$ oc annotate serviceaccount -n $APP_NAMESPACE kubecost-serviceaccount-cur-athena-thanos $IRSA_ROLE_ARN_CUR_ATHENA_THANOS
```

```bash
export IRSA_ROLE_THANOS=eks.amazonaws.com/role-arn=$APP_IAM_ROLE_ARN_THANOS
$ oc annotate serviceaccount -n $APP_NAMESPACE kubecost-serviceaccount-cur-athena-thanos $IRSA_ROLE_ARN_THANOS
```

### Step 9: Create required secret to store the configuration:

```sh
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```

### Step 10: Install kubecost:

#### Primary Cluster
```
helm upgrade --install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
--namespace kubecost \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values-thanos.yaml \
-f values-amazon-primary.yaml
```
#### Additional Clusters
```
helm upgrade --install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
--namespace kubecost \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values-thanos.yaml \
-f values-amazon-secondary.yaml
```
