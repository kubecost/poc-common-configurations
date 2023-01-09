# helm-kubecost

## Overview

This terraform was built as a basic example for using helm to deploy kubecost to a k8s cluster.

## Usage

1. You must first download the terraform client to run the terraform against your k8s cluster.  This terraform was original written and run with v1.3.7. You can find listings to the different versions of the terraform clients at the link below.

https://releases.hashicorp.com/terraform/

2. The terraform was written to utilize the local ~/.kube/config file by default.  Please make sure you are referencing the correct kube config file and are on the correct context before applying the terraform. If you are experienced with terraform, there are other options you can use to connect to the k8s cluster.  These changes can be made in main.tf the the helm provider and kubernetes provider block.  See link below with additional information.

https://registry.terraform.io/providers/hashicorp/helm/latest/docs#authentication

3. The terraform uses the standard values.yaml shipped with the kubecost helm charts by default.  If you wish to use a local version of your values.yaml, you can define that in lines 15-19 of the helm.tf file.

4. The terraform will deploy the latest kubecost helm charts by default.  If you wish to specify a specific chart version, you can do so in the terraform.tfvars file on lines 10 and 11 and uncommenting line 24 in the helm.tf file

5. The terraform provides the option to deploy additional values configurations not defined in default/referenced values.yaml file.  If you wish to deploy additional values changes, you can do so on lines 26-31 on the helm.tf file.  You can use the same format to add as many values changes you like.

## Notes

Before running the terraform, please be sure to be authenticated and can connect to the k8s cluster.