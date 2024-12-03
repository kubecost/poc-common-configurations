# Flux CD sample files for Kubecost Enterprise w/ Federated ETL

# Overview

These are the steps to enable ETL federation with Kubecost using Flux CD

Federated-ETL is an efficient method to implement multi-cluster Kubecost while using existing Prometheus installations for short-term metrics.

> Note: Kubecost can rebuild its data (ETLs) using the Prometheus metrics from each cluster. It is recommended to retain local cluster Prometheus metrics that meet an organization's disaster recovery requirements.


## Setup

###  Object-Store and Permissions Setup

Create an S3 compatible bucket to use for the Kubecost metrics and attach policy to kubecost service account.

Update [iam-kubecost-metrics-s3-policy](iam-kubecost-metrics-s3-policy) and [federated-store.yaml](federated-store.yaml) with your bucket name.

Then create the IAM Policy (note the ARN for the attach-policy-arn below):

```
aws iam create-policy \
 --policy-name kubecost-s3-federated-policy \
 --policy-document file://iam-kubecost-metrics-s3-policy.json
```

Create the secret for the object-store for kubecost federation:

```
kubectl create namespace kubecost
kubectl create secret generic \
  kubecost-object-store -n kubecost \
  --from-file federated-store.yaml
```

Creating a new service account:

```
eksctl utils associate-iam-oidc-provider \
    --cluster your-cluster-name \
    --region us-east-2 \
    --approve
eksctl create iamserviceaccount \
    --name kubecost-irsa-s3 \
    --namespace kubecost \
    --cluster your-cluster-name \
    --region us-east-2 \
    --attach-policy-arn arn:aws:iam::111222333:policy/kubecost-s3-federated-policy \
    --approve
```

Once this is complete, you can populate `kubecostModel.federatedStorageConfigSecret` with the object store secret name and `serviceAccount.name` with the irsa service account name in both `helmrelease-flux-primary.yaml` and `helmrelease-flux-secondary.yaml`

*Note: please DO NOT change the name of the file  `federated-store.yaml` . Kubecost requires the name of the file behind the secret to remain the same.


### Installation Process

The installation utilizes FluxCD to synchronize cluster configurations from a Git repository, automating deployment through Helm and Kustomize. Ensure your `kustomization.yaml` includes all necessary file names (like `helmrelease-flux-primary.yaml`, `helmrepo.yaml`, etc.). This step is crucial as it allows the Kustomize controller to recognize and apply configurations for resources such as Helm repositories and releases.

#### Installation on Primary Cluster

For the primary cluster, edit the `helmrelease-flux-primary.yaml` template to set the `CLUSTER_NAME` appropriately. The Git repository, pre-configured with FluxCD, orchestrates the deployment, leveraging Helm for package management and Kustomize for customization. This setup ensures a seamless and automated installation process.

#### Installation on Secondary Clusters

For secondary clusters, follow a similar process by using the templated `helmrelease-flux-secondary.yaml`. Ensure to adjust relevant configurations, like `CLUSTER_NAME`, to match the specific secondary cluster's details. The pre-configured Git repository with FluxCD will facilitate the deployment, utilizing Helm and Kustomize to automate and manage the installation seamlessly across all your secondary clusters.

### 4. (Optional) Configure Cloud Integration

Once the federated setup is complete, we recommend configuring the cloud integration for most accurate cost information in Kubecost.  Please follow the instructions in the doc link below to configure the cost report setup for your specific cloud provider.

AWS - https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations
GCP - https://docs.kubecost.com/install-and-configure/install/cloud-integration/gcp-out-of-cluster
Azure - https://docs.kubecost.com/install-and-configure/install/cloud-integration/azure-out-of-cluster

Once the cost report is configured for your cloud provider, for AWS we recommend NOT adding values directly to your values file as stated in the step at the link below.

https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations#option-2-add-config-values-via-helm

Instead please use the Multi-Cloud configuration option by follow the steps in the link below for your specific cloud provider.

https://docs.kubecost.com/install-and-configure/install/cloud-integration/multi-cloud

Once you have created the required secret, uncomment `kubecostProductConfigs.cloudIntegrationSecret` and populate the secret in `helmrelease-flux-primary.yaml` and apply the changes.


### Debugging Steps

If you encounter issues during the installation process, follow these debugging steps to diagnose and resolve problems:

1. Retrieve the list of Helm releases to check their status:
   ```
   flux get helmrelease -n flux-system
   ```

2. For detailed diagnostics, investigate the logs of the Flux Notification Controller and Helm Controller. These logs can provide insights into the operational processes and highlight any errors encountered:
   - Notification Controller logs:
     ```
     kubectl logs -n flux-system -l app=notification-controller
     ```
   - Helm Controller logs:
     ```
     kubectl logs -n flux-system -l app=helm-controller
     ```




