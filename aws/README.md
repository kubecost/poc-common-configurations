# AWS Setup

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


# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Below idea MAY work for scripting. tested on eks, aks, gke
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

helm upgrade kubecost "kubecost/cost-analyzer" --namespace kubecost --install -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values.yaml -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f values-amazon-primary.yaml --set networkCosts.enabled=true --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID
```

## All Secondary Clusters Setup

```bash
# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Below idea MAY work for scripting. tested on eks, aks, gke
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# AWS service key
kubectl create secret generic aws-service-key -n kubecost --from-file=service-key.json

helm upgrade kubecost "kubecost/cost-analyzer" --namespace kubecost --install -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values.yaml -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-amazon-secondary.yaml --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID
```
