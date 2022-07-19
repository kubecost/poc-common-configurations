This is still a work in progress, meant as an example method for attached an IAM role to the service account used by Kubecost.

There are multiple methods for doing this, if the method below does not fit your requirements, please reach out to us. 

Using aws with IAM roles attached to service accounts:

## Prerequisites:

1. You have Amazon EKS cluster set up using eksctl. If you have Amazon EKS cluster set up via different method, please refer to AWS documentation at [Enable IAM roles for Service Accounts (IRSA) on the EKS cluster](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)
2. You have approriate IAM permissions to manage Amazon EKS cluster and manage,create and assign AWS IAM.
3. Clone this repository into your machine and navigate to POC-COMMON-CONFIGURATION-TEST/aws-attach-roles
4. Remember to update cloud-integration.jon with approriate information of your Athena set up for Cost Usage Report (CUR). For more information, please refer to this [documentation](https://guide.kubecost.com/hc/en-us/articles/4407595928087-AWS-Cloud-Integration)

## Instructions:

0. Set up necessary ENV Variable:

```
AWS_object_store_bucket="<your-object-store-bucket-name>"
AWS-REGION="<your-desired-aws-region>"
YOUR-CLUSTER-NAME="<your-eks-cluster-name>"
```

1. Create Object store S3 bucket to store Thanos data:

`aws s3 mb s3://${AWS_object_store_bucket} --region `

2. Update configuration of these files: cloud-integration.json, kubecost-athena-policy.json, kubecost-s3-thanos-policy.json, object-store.yaml, productkey.json (optional if it is only for evaluation) accordingly with your information. The values that need to be updated is in <....>

3. Run the following commands to create approriate policy:

```sh
cd poc-common-configuration/aws-attach-roles
aws iam create-policy --policy-name kubecost-athena-policy --policy-document file://kubecost-athena-policy.json
aws iam create-policy --policy-name kubecost-s3-thanos-policy --policy-document file://kubecost-s3-thanos-policy.json
```

4. Enable oidc provider for your cluster:

```
kubectl create ns kubecost
eksctl utils associate-iam-oidc-provider \
    --cluster ${YOUR-CLUSTER-NAME} --region ${AWS-REGION} \
    --approve
```
5. Create required IAM service accounts. Please remember to replace 1111111111 with your actual AWS account ID #:

```
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount-cur-athena-thanos \
    --namespace kubecost \
    --cluster ${YOUR-CLUSTER-NAME} --region ${AWS-REGION} \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-athena-policy \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-s3-thanos-policy \
    --override-existing-serviceaccounts \
    --approve
```
```
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount-thanos \
    --namespace kubecost \
    --cluster ${YOUR-CLUSTER-NAME} --region ${AWS-REGION} \
    --attach-policy-arn arn:aws:iam::297945954695:policy/kubecost-s3-thanos-policy \
    --override-existing-serviceaccounts \
    --approve
```

6. Create required secret to store the configuration:

```sh
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```

7. Install kubecost:

```
helm upgrade --install kubecost kubecost/cost-analyzer \
--namespace kubecost \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values-thanos.yaml \
-f values-amazon-primary.yaml
```
