# Terraform to Deploy Enterprise Kubecost Configuration

## Pre-requisites

1. Assumes an EKS cluster already exists
2. Assumes the Namespace you are deploying Kubecost to already exists
3. Assumes your Kubecost Enterprise license key is stored in AWS SSM.

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
