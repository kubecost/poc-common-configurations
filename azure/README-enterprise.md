# Enterprise Edition Azure Setup

## Architecture

In Kubecost Enterprise Edition, there are two configurations needed. The first "Primary Cluster" runs the Kubecost UI/API and performs the cost reconciliation processes. All other clusters are "secondary" or "agent-only" and are configured with a minimal set of Kubecost components needed to gather metrics and ship back to a shared storage bucket.

Data from secondary clusters is sent every 3 hours.
Each cloud provider's billing is delayed between 6 and 24+ hours.
Many parts of the UI will not look healthy or accurate until a full [reconciliation](https://guide.kubecost.com/hc/en-us/articles/4412369153687-Cloud-Integrations#reconciliation) is complete.  If using Azure gov, then set the following in [cloud-integration](https://github.com/kubecost/poc-common-configurations/blob/main/azure/cloud-integration.json)


```bash 

"azureCloud": "gov" 
``` 

Helpful links:

1. [README](https://github.com/kubecost/poc-common-configurations#federated-cluster-views-enterprise-only)
1. [Architecture diagrams](https://guide.kubecost.com/hc/en-us/articles/4407595922711-Kubecost-Core-Architecture-Overview)
1. [Federated clusters guide](https://guide.kubecost.com/hc/en-us/articles/4407595946135-Federated-Clusters)
1. [Azure Storage Setup](README-azure-storage.md) for federated storage

***Be sure to update the kubecostProductConfigs.clusterName and prometheus.server.global.external_labels.cluster_id in the values.yaml files before the helm install.***
## Primary Cluster Setup

```bash
kubectl create namespace kubecost

# Create secret for product key # not needed for eval
# kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-federated-store -n kubecost --from-file=object-store.yaml

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

# Azure service key (optional)
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

helm upgrade --install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  -f ./values-azure-primary.yaml
```

## All Secondary Clusters Setup

>If your secondary clusters are in a different subscription, you will need to modify the service-key.json per subscription.
>cloud-integration is not needed on secondary clusters

```bash
kubectl create namespace kubecost
# Create secret for product key # not needed for eval
# kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store, this should be the same bucket as the primary
kubectl create secret generic kubecost-federated-store -n kubecost --from-file=object-store.yaml

# Azure service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

helm upgrade --install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  -f ./values-azure-secondary.yaml
```
