# Kubecost Setup for GCP

## Overview

This repository is designed to be an easy guide for the most common configurations of Kubecost in GCP. It does not replace our [published documentation](https://guide.kubecost.com/) which will have details for many more use cases.

---
## Usage

The configuration files (yaml/json) have placeholders for the variables needed. They are listed below in order to prevent duplicated efforts. The sample-values will look similar to yours.

The variables below are are denoted like this:
- `variable:  sample-value`

Just replace the `sample-value` with yours. The link at the top of each section will bring you to the Kubecost documentation with more detail.

---
When you have updated the corresponding values in the json and yaml files in this repository, follow the setup guide:

[Enterprise Setup](README-enterprise.md)

---

## Required Variables
### Cluster Name / ID (values*.yaml)
>Note that there are two places that this is used, in the kubecostProductConfigs.clusterName and prometheus.server.global.external_labels.cluster_id

- `kubecostProductConfigs_clusterName: gcp-cluster1`

---

### cloud-integration.json
https://guide.kubecost.com/hc/en-us/articles/4407601816087-GCP-Out-of-Cluster

> Note that many fields needed will be in the $SERVICE_ACCOUNT_NAME-key.json file
