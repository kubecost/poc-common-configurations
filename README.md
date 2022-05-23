# poc-common-configurations

## Overview

This repo contains sample configurations for both Business Edition and Enterprise Edition Kubecost environments. Each folder has been prefixed with the configuration specific to that subscription model.

A detailed overview of available subscriptions options are [here](https://www.kubecost.com/pricing/). The primary difference is that the the Enterprise model aggregates all cluster information into a single Kubecost UI while the Business model has a separate UI for each cluster and does not aggregate multiple clusters.

This repo is meant to supplement the documentation in the [Kubecost Guide](https://guide.kubecost.com/).

Please let us know if you would like examples added either in the github issues or contact us via [Slack](https://kubecost.slack.com/).

## Usage

> Note on security: it is generally not a good practice to store secrets/passwords to disk. Please follow your organization's security practices.

The [keys.txt](keys.txt) file contains links to the various sections of documentation that gives details to find each needed variable. The [update-keys.sh](update-keys.sh) script will find the given keys in the file needed with your values. This script is a work in progress. Please file issues or contact us on [Slack](https://kubecost.slack.com/).

## Notes

Many of the features enabled are only available with an [Enterprise subscription](https://www.kubecost.com/pricing). The examples in this repo are all designed for unlimited metric retention and [Federated](https://guide.kubecost.com/hc/en-us/articles/4407595946135-Federated-Clusters) visibility where all clusters are aggregated in a single pane of glass. The free tier is for a single cluster per company with 15 day metric retention.

## Federated Cluster Views (Enterprise only)

When you have multiple clusters- all clusters should use the same object-store.yaml for whichever storage platform you prefer. Examples of object-storage.yaml for [AWS S3](/aws/object-store.yaml)/[Azure Blob Storage](/azure/object-store.yaml)/[Google Cloud Storage Buckets](/gcp/object-store.yaml) are in each of the respective folders.

There are [additional storage options](https://thanos.io/tip/thanos/storage.md/) for the Thanos Bucket, please discuss these with Kubecost Engineers during a POC.

Kubecost supports secondary clusters in any of the various Kubernetes providers. As pictured in the diagram below- one cluster is the "Primary" that runs the Kubecost UI and runs various jobs for reconciling data with the cloud/pricing providers. The primary cluster uses the cloud-integration.json file which contains an array of credentials that Kubecost will use to query each provider for billing details in order to provide accurate costs.

Secondary clusters run the Kubecost "agent" only and only have a minimal UI designed for troubleshooting.

![Kubecost-enterprise-architecture](https://raw.githubusercontent.com/kubecost/docs/main/images/thanos-architecture.png)