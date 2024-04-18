# Kubecost Enterprise AWS Guide

This guide will allow Kubecost to federate multiple clusters into a single UI and integrate with AWS billing.

Following best practices, this guide does not use shared secrets. Some Kubernetes objects may be "secrets" but they are essentially just configMaps.

## Prerequisites

1. You have Amazon EKS cluster set up using eksctl. If you have EKS clusters set up via different method, please refer to AWS documentation at [Enable IAM roles for Service Accounts (IRSA) on the EKS cluster](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)
2. You have appropriate IAM permissions to manage Amazon EKS cluster and manage, create and assign AWS IAM.

## Instructions

### Getting started

- Set up necessary ENV Variable:

```sh
KUBECOST_METRICS_BUCKET="your-object-store-bucket-name"
AWS_REGION="your-desired-aws-region"
YOUR_CLUSTER_NAME="your-eks-cluster-name"
```

### Step 1: Create Object store S3 bucket to store Kubecost ETL data

```sh
aws s3 mb s3://$KUBECOST_METRICS_BUCKET --region $AWS_REGION
```

Considerations:

1. If your agent clusters are running on different AWS account, you need to set appropriate permission and IAM policy to allow Thanos sidecar put data on a central S3 bucket located on primary account. There are 2 ways to do that:

   1. S3 bucket policy: Set up S3 bucket policy to grant access to other AWS accounts. Example multi-account policy below.
   1. Cross AWS accounts IAM roles: Set up an IAM role with permission to access to the central S3 bucket and trusted policy to allow other AWS accounts to assume that IAM role to have access to the central S3 bucket.

1. You can read more on how to do it in official AWS documentation [here](https://aws.amazon.com/premiumsupport/knowledge-center/cross-account-access-s3/)

Example of S3 bucket policy that grant access to multiple AWS accounts:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::<ReplacewithAccount_B_ID>:root",
                    "arn:aws:iam::<ReplacewithAccount_C_ID>:root",
                    "arn:aws:iam::<ReplacewithAccount_D_ID>:root"
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
                "arn:aws:s3:::KUBECOST_METRICS_BUCKET/*",
                "arn:aws:s3:::KUBECOST_METRICS_BUCKET"
            ]
        }
    ]
}
```

### Step 2: AWS CUR Configuration (optional)

Follow this guide to allow Kubecost access to the AWS Payer Account billing data:
TO_DO: add link to new doc

### Step 3: Run the following commands to create the s3 metrics policy

```sh
aws iam create-policy --policy-name kubecost-metrics-s3-policy --policy-document file://iam-kubecost-metrics-s3-policy.json
```

### Step 4: Enable oidc provider for your cluster

```sh
kubectl create ns kubecost
eksctl utils associate-iam-oidc-provider \
    --cluster $YOUR_CLUSTER_NAME --region $AWS_REGION \
    --approve
```

### Step 5: Create required IAM service accounts

**Linking default Kubecost Service Account to an IAM Role**

Kubecost's default service account `kubecost-cost-analyzer` is automatically created in the `kubecost` namespace upon installation. This service account can be linked to an IAM Role via Annotation + IAM Trust Policy. 

In the Helm values for your deployment, add the following section:

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<accountNumber>:role/<kubecost-role>
```

Go to the IAM Role and attach the proper IAM trust policy. [Use the sample trust policy here](https://github.com/kubecost/poc-common-configurations/blob/main/aws/iam-policies/irsa-iam-role-trust-policy-for-default-service-account). Verify you have replaced the example OIDC URL with your cluster OIDC URL.

**Alternative method: Create a new dedicated service account for Kubecost using `eksctl`**

{% hint style="info" %}
This method creates a new service account via eksctl command line tools, instead of using the default service account. Eksctl automatically creates the trust policy and IAM Role that are linked to the new dedicated Kubernetes service account.
{% endhint %}

> **Note:** Please remember to replace 1111111111 with your actual AWS account ID #:

For the primary:

```sh
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount \
    --namespace kubecost \
    --cluster $YOUR_CLUSTER_NAME --region $AWS_REGION \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-access-cur-in-payer-account \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-metrics-s3-policy \
    --override-existing-serviceaccounts \
    --approve
```

For all agent clusters:
```sh
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount \
    --namespace kubecost \
    --cluster $YOUR_CLUSTER_NAME --region $AWS_REGION \
    --attach-policy-arn arn:aws:iam::1111111111:policy/kubecost-metrics-s3-policy \
    --override-existing-serviceaccounts \
    --approve
```

### Step 6: Create required secret to store the configuration:

```sh
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml
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
