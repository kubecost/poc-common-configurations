# Kubecost Setup for Azure

[Enterprise Setup](README-enterprise.md)

[Business Setup](README-business.md)


---


The configuration files (yaml/json) have placeholders for the variables needed. They are listed below in order to prevent duplicated efforts. The values will look similar to yours.

The variables below are are denoted like this:
- `variable: sample-value`

Just replace the `sample-value` with yours. The link at the top of each section will bring you to the Kubecost documentation with more detail.

---

## Cluster Name / ID (values*.yaml)
>Note that there are two places that this is used, in the kubecostProductConfigs.clusterName and prometheus.server.global.external_labels.cluster_id

- `kubecostProductConfigs_clusterName: azure-cluster1`

---

## service-key.json
https://guide.kubecost.com/hc/en-us/articles/4407595934871-Azure-Config

- `AZ_service_key_subscriptionId: 0bd50fdf-c923-4e1e-850c-196SAMPLE`
- `AZ_service_key_appId: 4031c763-c060-45c4-8a72-SAMPLE`
- `AZ_service_key_displayName: SAMPLE-azureratecard`
- `AZ_service_key_password: HMBI2oJQdvOUlG_cSAMPLE`
- `AZ_service_key_tenant: 72faf3ff-7a3f-4597-b0d9-7b0SAMPLE`

---

## cloud-integration.json

https://guide.kubecost.com/hc/en-us/articles/4407595968919-Setting-Up-Cloud-Integrations

- `AZ_cloud_integration_subscriptionId: 0bd50fdf-c923-4e1e-850c-196SAMPLE`
- `AZ_cloud_integration_azureStorageAccount: kubecostexport`
- `AZ_cloud_integration_azureStorageAccessKey: SX30SC4ZoccBKS7/Jj85rv/fmxb3Z41zRpcuSyh85J7+SAMPLE==`
- `AZ_cloud_integration_azureStorageContainer: costexports`

---

## object-store.yaml

https://guide.kubecost.com/hc/en-us/articles/4407595954327-Azure-Long-Term-Storage

- `AZ_object_store_storage_account: samplestorageaccount`
- `AZ_object_store_storageAccount_key: TYZgljfzaNFp/oZIGnmjQnqf4dI4KWXmXep3EBwEl+kj4GWEcx82vSAMPLE==`
- `AZ_object_store_container: dev-cluster1`
- `AZ_object_store_endpoint: blob.core.windows.net`