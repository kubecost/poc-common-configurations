# poc-common-configurations

## Overview

This repo contains sample configurations for Kubecost Enterprise Edition.

A detailed overview of available subscriptions options are [here](https://www.kubecost.com/pricing/).

This repo is meant to supplement the documentation in the [Kubecost Guide](https://docs.kubecost.com/).

Please let us know if you would like examples added either in the github issues or contact us via [Slack](https://kubecost.slack.com/).

## Usage

Most users should follow the [ETL Federation setup](etl-federation/README.md) as it is the most scalable and flexible. This architecture supports both using existing prometheus instances or the Kubecost bundled version.

In addition to the Federated ETL setup, please follow the cloud-integration guide for the respective cloud providers in the AWS/Azure/GCP folders.