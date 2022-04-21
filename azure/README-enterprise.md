# Enterprise Edition Azure Setup


## Primary Cluster Setup

```bash
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n nightly --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n nightly --from-file=object-store.yaml

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n nightly --from-file=cloud-integration.json

# Azure service key
kubectl create secret generic azure-service-key -n nightly --from-file=service-key.json

# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Set cluster names in values-primary and values-secondary (per cluster) or via script using with the this kubectl config command and pass the values to: --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID --set kubecostProductConfigs.clusterName=$CLUSTER_ID
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

helm install kubecost "kubecost/cost-analyzer" --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values-thanos.yaml -f ./values-azure-primary.yaml --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID --set kubecostProductConfigs.clusterName=$CLUSTER_ID
```

## All Secondary Clusters Setup

>If your secondary clusters are in a different subscription, you may want to create a copy of this repository and modify the service-key.json per subscription.
>cloud-integration is not needed on secondary clusters

```bash
kubectl create namespace kubecost
# Create secret for product key
# Create secret for product key (not needed during eval)
# kubectl create secret generic productkey -n nightly --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n nightly --from-file=object-store.yaml

# Azure service key
kubectl create secret generic azure-service-key -n nightly --from-file=service-key.json

# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Set cluster names in values-primary and values-secondary (per cluster) or via script using with the this kubectl config command and pass the values to: --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID --set kubecostProductConfigs.clusterName=$CLUSTER_ID
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

helm upgrade --install kubecost "kubecost/cost-analyzer" --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values-thanos.yaml -f ./values-azure-secondary.yaml --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID --set kubecostProductConfigs.clusterName=$CLUSTER_ID
```
