# Grafana Dashboards

## Network costs PromQL

### Internet
```
sum by(namespace) (increase(kubecost_pod_network_egress_bytes_total{internet="true", namespace=~"$Namespace", cluster_id=~"$cluster", pod_name=~"$pod"}[60m])) / 1024 / 1024
```

### Cross Region (must define region in network-cost configmap)
```
sum by(namespace) (increase(kubecost_pod_network_egress_bytes_total{internet="false", namespace=~"$Namespace", cluster_id=~"$cluster", pod_name=~"$pod", sameRegion="true", sameZone="false"}[60m])) / 1024 / 1024
```

### Cross Zone
```
sum by(namespace) (increase(kubecost_pod_network_egress_bytes_total{internet="false", namespace=~"$Namespace", cluster_id=~"$cluster", pod_name=~"$pod", sameZone="true"}[60m])) / 1024 / 1024
```