# Install Kubecost in Azure air-gapped 

## Primary Cluster

```
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

# Azure service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

helm install kubecost "kubecost/cost-analyzer" --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-primary.yaml
```

## Secondary Clusters:

```
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for Thanos store
kubectl create secret generic kubecost-thanos -n kubecost --from-file=object-store.yaml

# Azure service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

helm install kubecost "kubecost/cost-analyzer" --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-thanos.yaml -f ./values-secondary.yaml
```

## Azure blob storage for kubecost object-store:

```
storageAccount="jessestorageaccount2"
containerName="dev-cluster1"
storageResourceGroup="jesse-storage-resource-group"

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
