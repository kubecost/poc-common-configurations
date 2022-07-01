## Considerations for Azure Private Storage

Kubecost supports Azure private endpoints for storage following this guide: <https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints>
And a tutorial here: <https://docs.microsoft.com/en-us/azure/private-link/tutorial-private-endpoint-storage-portal>

## Azure blob storage for kubecost object-store

In general, follow the Azure guide: <https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal>

Example of the commands needed are below. Note that the az-cli/api may change- in which case, please reference the above guide to create a blob storage account.

```bash
storageAccount="YOURNAMEstorageaccount"
containerName="kubecost-metrics"
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
