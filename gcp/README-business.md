# Business Edition GCP

## All Clusters Setup

```bash
kubectl create namespace kubecost
# Create secret for product key
kubectl create secret generic productkey -n kubecost --from-file=productkey.json

# Create Cloud Integration Secret
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json

helm upgrade kubecost "kubecost/cost-analyzer" --install --namespace kubecost -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values.yaml -f ./values-google-primary.yaml
```

