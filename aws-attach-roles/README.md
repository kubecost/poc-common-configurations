>This guide is in development, please send feedback via Github issues.

# Using Kubecost with IRSA

This guide has the steps to enable IAM Roles for Service Accounts (IRSA) for the service account used by Kubecost.

There are multiple methods for doing this, if the method below does not fit your requirements, please reach out to us.

## Prerequisites:

1. You have Amazon EKS cluster set up using eksctl, but will be similar for other setups that can leverage OIDC authentication of Kubernetes service accounts. Please refer to the AWS documentation at [Enable IAM roles for Service Accounts (IRSA) on the EKS cluster](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)
2. You have appropriate IAM permissions to manage Amazon EKS cluster and manage,create and assign AWS IAM.
3. Clone this repository into your machine and navigate to poc-common-configurations/aws-attach-roles. Example commands:
```bash
git clone https://github.com/kubecost/poc-common-configurations.git
cd poc-common-configurations/aws-attach-roles
```
5. Remember to update [cloud-integration.json](https://github.com/kubecost/poc-common-configurations/blob/main/aws-attach-roles/cloud-integration.json) with appropriate information of your Athena set up for Cost Usage Report (CUR). For more information, please refer to this [documentation](https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations)

## Instructions:

### Prerequisites:
- Set up necessary ENV Variable:

```
BUCKETNAME="<your-object-store-bucket-name>"
AWS_REGION="<your-desired-aws-region>"
YOUR_CLUSTER_NAME="<your-eks-cluster-name>"
```

### Step 1: Create Object store S3 bucket to store Thanos data:

`aws s3 mb s3://${BUCKETNAME} --region `

- If your 2nd cluster is running on different AWS account, you need to set appropriate permission and IAM policy to allow Thanos sidecar put data on a central S3 bucket located on primary account. There are 2 ways to do that:

    * **S3 bucket policy:** Set up S3 bucket policy to grant access to other AWS accounts.
    * **Cross AWS accounts IAM roles:** Set up an IAM role with permission to access to the central S3 bucket and trusted policy to allow other AWS accounts to assume that IAM role to have access to the central S3 bucket.

- You can read more on how to do it in official AWS documentation [here](https://aws.amazon.com/premiumsupport/knowledge-center/cross-account-access-s3/)

- For POC deployment and standard set up, we recommend to use **S3 bucket policy** option. However, you can use **Cross AWS accounts IAM roles** if you need more advanced set-up to comply with your organization policy.
- Examples:

    * This is an example of S3 bucket policy that grant access to additional AWS accounts:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::ACCOUNT_NUMBER_A:root",
                    "arn:aws:iam::ACCOUNT_NUMBER_B:root",
                    "arn:aws:iam::ACCOUNT_NUMBER_C:root"
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
                "arn:aws:s3:::${BUCKETNAME}/*",
                "arn:aws:s3:::${BUCKETNAME}"
            ]
        }
    ]
}
```

   * This is an example of IAM policy you need to add on non-primary AWS accounts to have access to the central S3 bucket:


```json
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
                "arn:aws:s3:::${BUCKETNAME}/*",
                "arn:aws:s3:::${BUCKETNAME}"
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

### Step 4: Enable oidc provider for your cluster:

```
kubectl create ns kubecost
eksctl utils associate-iam-oidc-provider \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --approve
```
### Step 5: Create required IAM service accounts.

> **Note:** Please remember to replace 1111111111 with your actual AWS account ID #:

```
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount-cur-athena-thanos \
    --namespace kubecost \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-athena-policy \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-s3-thanos-policy \
    --override-existing-serviceaccounts \
    --approve
```
```
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount-thanos \
    --namespace kubecost \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-s3-thanos-policy \
    --override-existing-serviceaccounts \
    --approve
```

### Step 6: Create required secret to store the configuration:

```sh
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```

### Step 7: Install kubecost:

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
