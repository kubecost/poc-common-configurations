```
helm upgrade grafana grafana --namespace grafana --install --create-namespace --repo https://grafana.github.io/helm-charts
helm upgrade kubecost kubecost/cost-analyzer --install --namespace kubecost --create-namespace -f values-grafana.yaml
```

