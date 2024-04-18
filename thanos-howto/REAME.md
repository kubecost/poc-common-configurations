# Thanos Store

Modify [values-thanos.yaml](values-thanos.yaml) to fit your needs.

Install Thanos

```sh
helm install thanos -n thanos --create-namespace \
  --repo https://charts.bitnami.com/bitnami thanos \
  -f values-thanos.yaml
```

Add the thanos-query-frontend as your default Kubecost Grafana datasource.

[values-kubecost-datasource.yaml](values-kubecost-datasource.yaml)
