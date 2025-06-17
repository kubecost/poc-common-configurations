# Monitoring Kubecost with Prometheus AlertManager

![Example Alert](./images/example-alert.png)

## Usage

To start testing these alerting rules, you can apply these additional configs to your Kubecost primary cluster. Eventually they will need to be applied to every cluster Kubecost is monitoring.

```bash
helm upgrade -i kubecost kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ 
  -f values.yaml
```

## Thanos Users

If you are a Thanos user, you still have the option of monitoring each individual cluster using the above method. If you would instead like to fire alerts based on queries to the central Thanos Store, you will need to configure [Thanos Ruler](https://thanos.io/tip/components/rule.md/).

Thanos Ruler is not currently supported in the `cost-analyzer-helm-chart`. Here is a [chart](https://github.com/bitnami/charts/tree/main/bitnami/thanos) which does include Ruler.

Below are some example alerts that can be used:

```yaml
alerting_rules.yml:
  groups:
  - name: Alerts
    rules:

    # Test alert
    - alert: Control
      expr: avg(node_total_hourly_cost offset 3h) by (cluster_id) > 0
      for: 0m
      labels:
        severity: test
      annotations:
        summary: This alert acts as a control, and should always fire. Remove this when done testing.

    # Compare number of unique cluster_ids 3h ago to 1d ago. Alert if we
    # now have fewer cluster_ids. If you intentionally remove a cluster
    # from being monitored by Kubecost, these alerts will fire for ~1d.
    - alert: MissingKubecostMetrics
      expr: count(avg(node_total_hourly_cost offset 3h) by (cluster_id)) < count(avg(node_total_hourly_cost offset 1d) by (cluster_id))
      for: 3h
      labels:
        severity: critical
      annotations:
        summary: Kubecost metric is missing from one or more clusters. Alert if missing for at least 3 hours.
```

## Testing

If you'd like to quickly test the alerting rule without performing a `helm upgrade`, you can do the following:

1. `kubectl edit configmap/kubecost-prometheus-server`
2. Add your alerting rules under the `alerting_rules.yml` section of the configmap
3. Restart the prometheus-server or the thanos-query pod
