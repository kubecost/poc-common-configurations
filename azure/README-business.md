# Business Edition Azure Setup

## Architecture

In Kubecost Business Edition, all clusters are configured identically. Each cluster has the ability to switch to other clusters via the Kubecost Homepage or via the Switch Cluster function in the UI.

*Kubecost Homepage*

![Kubecost-homepage](../images/kubecost-homepage.png)

*Switch Cluster*

![Kubecost-switch-cluster](../images/kubecost-switch-clusters.png)

>Note that the use of Thanos is not included in Business edition and all clusters wil have an independent Kubecost UI

## All Clusters Setup

```bash
kubectl create namespace kubecost
# Create secret for product key
# Create secret for product key (not needed during eval)
# kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

# Azure service key
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json

# Each CLUSTER_ID must be unique:
CLUSTER_ID="YOUR_CLUSTER_NAME"
# Set cluster names in values-primary and values-secondary (per cluster) or via script using with the this kubectl config command and pass the values to: --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID --set kubecostProductConfigs.clusterName=$CLUSTER_ID:
CLUSTER_ID="$(kubectl config current-context | cut -d '/' -f2)"

helm install kubecost "kubecost/cost-analyzer" --namespace kubecost -f ./values-azure-primary.yaml --set prometheus.server.global.external_labels.cluster_id=$CLUSTER_ID --set kubecostProductConfigs.clusterName=$CLUSTER_ID
```
