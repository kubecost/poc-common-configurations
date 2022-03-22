# Install Kubecost in Azure

## Considerations for Azure Private Storage

Kubecost supports Azure private endpoints for storage following this guide: <https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints>
And a tutorial here: <https://docs.microsoft.com/en-us/azure/private-link/tutorial-private-endpoint-storage-portal>

## Azure blob storage for kubecost object-store

Follow the Azure guide: <https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal>

General commands needed are below Note that the az-cli/api may change- in which case, please reference the above guide to create a blob storage account.

```bash
storageAccount="YOURNAMEstorageaccount"
containerName="dev-cluster1"
storageResourceGroup="YOURNAME-storage-resource-group"

az group create \
  --name $storageResourceGroup \
  --location centralus

az storage account create \
  --name $storageAccount \
  --resource-group $storageResourceGroup \
  --location centralus \
  --sku Standard_RAGRS \
  --kind StorageV2

az storage account keys list \
    --resource-group $storageResourceGroup \
    --account-name $storageAccount

# Create a container object
az storage container create \
    --name $containerName \
    --account-name $storageAccount \
    --auth-mode login
```

## Primary Cluster Setup

```bash
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

# Azure service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Below idea MAY work for scripting. tested on eks, aks, gke
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

helm install kubecost "kubecost/cost-analyzer" --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values.yaml -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-azure-primary.yaml --set networkCosts.enabled=true --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID
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

# Azure service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

helm upgrade kubecost "kubecost/cost-analyzer" --namespace kubecost --install -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values.yaml -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-azure-secondary.yaml --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID
```
