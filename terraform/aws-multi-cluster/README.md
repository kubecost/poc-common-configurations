# Terraform to Deploy Enterprise Kubecost Configuration

# Goal 
Use Terraform to deploy all components for Kubecost in Primary and Secondary cluster in multiple AWS accounts.

## Pre-requisites

1. Clusters are in multiple AWS accounts. There is one primary cluster in one account - primary account, secondary clusters in same and other AWS accounts. 
1. EKS clusters already exist
1. Namespace you are deploying Kubecost to already exist - in primary and secondary clusters.
1. Assumes your Kubecost Enterprise license key is with you.
1. Cur bucket is already created and this module is going to create pipeline to read from it.

## Testing

```bash
# 1. Copy the contents of this `aws-multi-cluster` folder.

# 2. It is recommended to apply Kubecost primary resources first
cd test-primary

# 3. Modify the variables set in `main.tf`

# 4. Terraform time!
terraform init
terraform plan
terraform apply
```

# Implementation on high level

1. [Apply Enterprise License](https://docs.kubecost.com/install-and-configure/advanced-configuration/add-key), store it in SSM if you want it safe, or can be manual.
1. Set up S3 bucket in primary accounts. This is to metrics data to central bucket in primary account. Secondary accounts should be able to push/pull to S3 bucket
1. AWS Cloud Integration [Using IRSA](https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-cloud-integration-using-irsa)
1. Federation Configuration: Secondary accounts needs to access `S3 bucket in primary accounts`. 
    1. Set up a role in every account with S3 read/write permissions
    1. Set up S3 bucket and  grant access to every other secondary accounts
1. Cloud Cost Integration Configuration. Create up CUR data processing pipeline and S3 bucket for Athena in primary account only. This is store storage for athena query results.


# Architecture Digram

![Architecture Digram](./kubecost.png)