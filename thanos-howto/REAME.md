# Thanos Store

This is a very basic guide. Thanos is supported by Kubecost Enterprise and our Team is happy to assist with customization.

## Prerequisites

Thanos writes to an S3 bucket. You will need to create an S3 bucket and a user with permissions to write to it.

> any cloud provider object-storage works.

The policy for this is similar to [iam-kubecost-metrics-s3-policy.json](../aws/iam-policies/iam-kubecost-metrics-s3-policy.json)


## Installation

- Modify [values-thanos.yaml](values-thanos.yaml) to fit your needs.

- Install Thanos, preferably in the same cluster as Kubecost Primary:

```sh
helm install thanos -n thanos --create-namespace \
  --repo https://charts.bitnami.com/bitnami thanos \
  -f values-thanos.yaml
```

- Primary Only: Add the thanos-query-frontend as your default Kubecost Grafana datasource. This is added to your existing Kubecost values. [values-kubecost-datasource.yaml](values-kubecost-datasource.yaml)

- Both agents (secondary clusters) and the Primary will need to ship metrics to Thanos via the prometheus sidecar. [values-thanos-prometheus-sidecar.yaml](values-thanos-prometheus-sidecar.yaml)

- This file expects at secret named `kubecost-thanos` with the file name of object-store.yaml.

```sh
kubectl create secret generic kubecost-thanos --from-file object-store.yaml
```

When done, upgrade Kubecost to use the new values.

```sh
helm upgrade kubecost -n kubecost \
  --repo https://kubecost.github.io/cost-analyzer cost-analyzer \
  -f values-kubecost.yaml
```

