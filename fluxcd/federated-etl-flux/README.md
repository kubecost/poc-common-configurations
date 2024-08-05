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

## Kubecost Additional Plugins

This section introduces additional plugins that extend the functionality of Kubecost, focusing on Kubecost Actions and Carbon Costs. These plugins provide more granular insights and control over your cloud spending and environmental impact.

### Carbon Costs

The Carbon Costs plugin (also see: [official docs](https://docs.kubecost.com/using-kubecost/carbon-costs)) adds a unique metric to both the Allocation and Assets dashboards within Kubecost. This metric, measured in kilograms of CO2 equivalent (KG CO2e), follows the Environmental Protection Agency (EPA)'s definition:

> **Carbon dioxide equivalent (CO2e)** is the measure used to compare the emissions from various greenhouse gases based on their global warming potential (GWP). The CO2e for any gas is calculated by multiplying the tons of the gas by the associated GWP. \(CO2e = Metric Tons x GWP of the gas\).

Kubecost leverages carbon coefficient data sourced from the Cloud Carbon Footprint initiative, attributing estimated carbon costs to various assets such as disk, node, and network resources, based on their operational runtime. These costs are subsequently allocated across different resources to provide a comprehensive view of environmental impact. For deeper insights into the coefficients' methodology, refer to the [Cloud Carbon Footprint's methodology page](https://www.cloudcarbonfootprint.org/docs/methodology).


### Kubecost Actions

[Kubecost Actions](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions) is a powerful feature that allows you to create and manage automated savings actions directly within your Kubecost environment. Actions enable you to optimize cost management through a variety of strategies such as cluster turndown, request sizing, and namespace turndown, among others.

#### Enabling Kubecost Actions
To utilize Kubecost Actions, you first need to enable the Cluster Controller, which provides Kubecost administrative access to perform the actions. Note that this feature should be used with caution, as it allows write access to your cluster and can perform irreversible actions. Always ensure you have a backup before enabling.

#### Action Capabilities
- **Cluster Turndown:** Schedule the spin-down of clusters during idle times to save costs.
- **Request Sizing:** Automatically right-size container requests to prevent over-provisioning.
- **Namespace Turndown:** Manage and delete idle workloads to maintain efficiency in resource usage.

#### Creating an Action
In the Actions page, you can create a new action or manage existing ones. Choose from predefined actions like cluster turndown or request sizing, and configure them according to your needs. For experimental features like Guided Sizing and Cluster Sizing, enable them in the settings under 'Enable experimental features'.

For a complete guide on how to enable and manage Kubecost Actions, including detailed configurations and recommendations, please visit the official documentation page: [Kubecost Actions Documentation](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions#enabling-kubecost-actions).


## Plugin Configuration in `helmrelease-plugins.yaml`

To enable the Carbon Costs and Kubecost Actions features, there is a seperate template file called `helmrelease-plugins.yaml` , where we have outlined all of the configs that you can add to your release yaml. Note that , all of the configs go into your primary cluster's helm release.

### Configuring Plugins on Your Primary Cluster

All plugin configurations, including Carbon Costs and the various Kubecost Actions (Cluster Turndown, Namespace Turndown, Cluster Sizing), should be conducted on your primary cluster. The `helmrelease-plugins.yaml` file has been meticulously crafted to provide detailed settings for each action, facilitating significant infrastructure cost savings.

It's important to ensure that the plugin configurations templates are correctly implemented in the `helmrelease-plugins.yaml` to enable these features fully. 

For more guidance on configuring the `helmrelease-plugins.yaml` file for different Kubecost actions and ensuring optimal savings. Each section is tailored to help you efficiently configure and manage the respective features to maximize your infrastructure's cost-efficiency.




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




