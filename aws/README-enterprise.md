# Enterprise Edition AWS Setup

## Architecture

In Kubecost Enterprise Edition, there are two configurations needed. The first "Primary Cluster" runs the Kubecost UI/API and performs the cost reconciliation processes. All other clusters are "secondary" or "agent-only" and are configured with a minimal set of Kubecost components needed to gather metrics and ship back to a shared storage bucket.

Helpful links:

1. [README](https://github.com/kubecost/poc-common-configurations#federated-cluster-views-enterprise-only)
1. [Architecture diagrams](https://guide.kubecost.com/hc/en-us/articles/4407595922711-Kubecost-Core-Architecture-Overview)
1. [Federated clusters guide](https://guide.kubecost.com/hc/en-us/articles/4407595946135-Federated-Clusters)

## Primary Cluster Setup

``` bash
kubectl create namespace kubecost

# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# Create secret for AWS Athena / Spot Pricing Access
kubectl create secret generic aws-service-key -n kubecost --from-file=service-key.json

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

helm upgrade kubecost "kubecost/cost-analyzer" --namespace kubecost --install -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f values-amazon-primary.yaml
```

## All Secondary Clusters Setup

>If your secondary clusters are in a different subscription, you may want to create a copy of this repository and modify the service-key.json per subscription.
>cloud-integration is not needed on secondary clusters

```bash
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# AWS service key
kubectl create secret generic aws-service-key -n kubecost --from-file=service-key.json

helm upgrade kubecost "kubecost/cost-analyzer" --namespace kubecost --install -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-amazon-secondary.yaml
```
