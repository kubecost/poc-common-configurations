# Flux CD sample files for Kubecost Enterprise

Many thanks to @jash2105 for the amazing write up for this. 
This configuration guide is provided as-is with best effort support for Kubecost Enterprise users. Kubecost support has limited experience with FluxCD.

## federated-etl-flux
In this folder you will find an example of deploying Kubecost using the Federated ETL method for data federation

### Prerequisites

Follow ReadMe-Enterprise to setup object-storage secrets for your given cloud provider:
- [AWS](../aws/README-enterprise.md)
- [Azure](../azure/README-enterprise.md)
- [GCP](../gcp/README-enterprise.md)

 > The installation below assumes you have created the kubecost namespace and kubecost-thanos secrets prior to running the commands.
 > Also note that while you are free to perform this integration, we provide best effort support for our Free customers.

### Setting up Kubecost with Flux CD

## Prerequisites

Before proceeding with setting up Kubecost using FluxCD, ensure that the following prerequisites are met:

1. **FluxCD Installation:** FluxCD should be installed and running in your Kubernetes cluster. If FluxCD is not yet installed, please refer to the [official FluxCD documentation](https://fluxcd.io/docs/installation/) for installation instructions.

2. **Flux CLI:** Make sure that the Flux CLI (`flux`) is installed on your local machine. The Flux CLI is essential for interacting with FluxCD, such as syncing changes and monitoring deployments. Instructions for installing the Flux CLI can be found [here](https://fluxcd.io/docs/cmd/).

3. **Git Repository Configuration with Flux:** A Git repository must be configured with FluxCD to track and manage the state of your Kubernetes cluster. FluxCD utilizes this repository to view reconciliations, updates, and trigger deployments based on changes pushed to the repository. If you haven't configured a Git repository with FluxCD yet, follow the [official FluxCD GitOps workflow](https://fluxcd.io/flux/cmd/flux_create_source_git/) guide for configuration instructions.

Ensure that your Git repository is equipped with webhooks to automatically trigger FluxCD reconciliations and deployments upon changes. This ensures that your Kubernetes cluster remains in sync with the desired state defined in your Git repository.

## Installation Guide

To install Kubecost using FluxCD, we leverage the HelmRelease and HelmRepository controllers provided by FluxCD. Instead of the traditional Helm installation method, FluxCD automates the deployment process based on YAML configuration files stored in your Git repository.

### Helm Repository Configuration

1. **Locate HelmRepository File:** Navigate to the `federated-etl-flux` folder within the `fluxcd` directory. Inside this folder, you'll find a file named `helmrepo.yaml`.

2. **Understanding HelmRepository Configuration:** The `helmrepo.yaml` file specifies the Helm chart repository URL and other necessary details for FluxCD to retrieve the charts. This allows FluxCD to manage Helm releases using charts from the specified repository.

### Helm Release Deployment

1. **Locate HelmRelease File:** Within the `federated-etl-flux` folder, you'll find another YAML file, typically named `helmrelease.yaml`. This file contains the configuration for deploying Kubecost using HelmRelease.

2. **Understanding HelmRelease Configuration:** The `helmrelease.yaml` file defines the desired state of the Kubecost deployment using Helm charts. FluxCD continuously monitors this file for changes. When updates are detected, FluxCD automatically reconciles the state of the Kubernetes cluster with the desired state specified in the HelmRelease file.

### Deployment Automation with FluxCD

1. **Push YAML Files to Git Repository:** Once the `helmrepo.yaml` and `helmrelease.yaml` files are configured according to your requirements, ensure they are located in the `federated-etl-flux` folder. Then, push these files to your Git repository (e.g., GitLab).

2. **FluxCD Synchronization:** FluxCD monitors the Git repository for changes within the `federated-etl-flux` folder. Upon detecting updates to the `helmrepo.yaml` or `helmrelease.yaml` files, FluxCD pulls the changes and applies them to the Kubernetes cluster. This ensures that the Kubecost deployment remains synchronized with the desired configuration.

By following this approach, you delegate the responsibility of managing Kubecost deployments to FluxCD, which automates installation and updates based on changes pushed to the Git repository.




