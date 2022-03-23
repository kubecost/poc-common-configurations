# poc-common-configurations

## Overview

This repo contains sample configurations for using federated clusters for the most common providers.

Each of the aws/azure/gcp folders contain the recommended configuration for the primary and all secondary clusters using the native object storage of the given provider.

This is meant to supplement the documentation in the [Kubecost Guide](https://guide.kubecost.com/).

Please let us know if you would like examples added either in the github issues or contact us via [Slack](https://kubecost.slack.com/).

## Usage

They [keys.txt](keys.txt) file contains links to the various sections of documentation that give detailed how-to for each needed variable. The [update-keys.sh](update-keys.sh) script will find the given keys in the file needed with your values. This script is a work in progress. Please file issues or contact us on [Slack](https://kubecost.slack.com/).

## Notes

Kubecost supports secondary clusters in any of the various Kubernetes providers. In general you would use one cluster in one provider as the Primary and use secondary clusters for all other clusters. The cloud-integration.json file contains and array of credentials that the primary cluster will use to query each provider.

Kubecost also support custom pricing via various methods.