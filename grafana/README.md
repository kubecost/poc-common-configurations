# Grafana Dashboards

If you do not use the Kubecost included prometheus, your `cluster_id` key may be simply `cluster` and `pod_name` may be `pod` etc.

## Screenshot

![grafana-kubecost-network-data](../images/kubecost-network-data.png)

## Network costs PromQL

### Internet
```
sum by(namespace) 
(increase(kubecost_pod_network_egress_bytes_total
{internet="true", 
namespace=~"$Namespace", 
cluster_id=~"$cluster", 
pod_name=~"$pod"
}[60m])) / 1024 / 1024
```

### Cross Region (must define region in network-cost configmap)
```
sum by(namespace) 
(increase(kubecost_pod_network_egress_bytes_total
{internet="false", sameRegion="true", sameZone="false",
namespace=~"$Namespace", 
cluster_id=~"$cluster", 
pod_name=~"$pod"
}[60m])) / 1024 / 1024
```

### Cross Zone
```
sum by(namespace) 
(increase(kubecost_pod_network_egress_bytes_total
{internet="false", sameZone="true",
namespace=~"$Namespace", 
cluster_id=~"$cluster", 
pod_name=~"$pod"
}[60m])) / 1024 / 1024
```
