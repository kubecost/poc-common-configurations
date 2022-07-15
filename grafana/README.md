```
helm install grafana grafana --namespace grafana --create-namespace --repo https://grafana.github.io/helm-charts --version 8.3.2
helm upgrade kubecost kubecost/cost-analyzer -n kubecost --install --create-namespace -f values-grafana.yaml
```

