# Red Hat OpenShift

## Overview

This folder contains sample custom resources definition (CRD) to deploy Kubecost using Kubecost operator. Please find more information in our official documentation at https://guide.kubecost.com/hc/en-us/articles/10248765796375-Deploy-Kubecost-from-Red-Hat-Openshift-s-OperatorHub-

Please let us know if you would like examples added either in the github issues or contact us via [Slack](https://kubecost.slack.com/).

## Usage

1. Install Kubecost operator following the instruction at: https://guide.kubecost.com/hc/en-us/articles/10248765796375-Deploy-Kubecost-from-Red-Hat-Openshift-s-OperatorHub-
2. Apply the CRD templates that meets your requirements from this folder.

```shell
kubectl apply -f <crd-template.yaml>
``` 