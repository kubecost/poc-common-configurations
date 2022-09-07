# Business Edition AWS

## Architecture

In Kubecost Business Edition, all clusters are configured identically. Each cluster has the ability to switch to other clusters via the Kubecost Homepage or via the Switch Cluster function in the UI.

*Kubecost Homepage*

![Kubecost-homepage](../images/kubecost-homepage.png)

*Switch Cluster*

![Kubecost-switch-cluster](../images/kubecost-switch-clusters.png)

>Note that the use of Thanos is not included in Business edition and all clusters wil have an independent Kubecost UI

## All Clusters Setup

``` bash
kubectl create namespace kubecost

# Create secret for product key - Not needed for eval
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create secret for AWS Spot Pricing Access and IP Address and Unattached Disks
kubectl create secret generic aws-service-key -n kubecost --from-file=service-key.json

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

helm upgrade kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost --install -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values.yaml -f values-amazon-primary.yaml
```
