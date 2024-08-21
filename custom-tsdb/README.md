# Using Kubecost without bundled Prometheus

See <https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom> for official Kubecost documentation for using Kubecost with an existing Prometheus instance.

## Diagnostics pod

A diagnostics pod is available for validating that required metrics are met: [readme](../metric-diagnostics/README.md).

## Notice

> The remainder of this document is dated. See official docs for the most up-to-date information.

## Kubecost with existing multi-cluster aggregated metrics

There are multiple methods for implementing Kubecost using existing Prometheus instances. The method below assumes that there is a method to ship all metrics to a central Prometheus store (Thanos/Mimir/Grafana Cloud/AWS Managed Prometheus/etc). These methods tend not to scale well in very large environments.

Kubecost recommends using [ETL Federation](https://docs.kubecost.com/install-and-configure/install/multi-cluster/federated-et) in large environments. Configuration here:[ETL Federation with existing Prometheus](../etl-federation/existing-prometheus/README.md)

 > Note that this script can be used to determine if any metrics are missing from the local Prometheus instance: [https://github.com/kubecost/poc-common-configurations/tree/main/custom-tsdb](https://github.com/kubecost/poc-common-configurations/tree/main/custom-tsdb)

 > Multi-cluster requires an enterprise subscription


## Installation

In addition to the settings below, each cluster must scrape the kubecost exporter.

To scrape the Kubecost exporter, either use Kubecost serviceMonitor (in the yaml config for both primary and secondaries) or see [extraScrapeConfigs.yaml](extraScrapeConfigs.yaml).

Negative idle costs are almost always a result of missing these metrics.

### Primary cluster install

```sh
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f values-primary.yaml
```

### Secondary clusters run a minimal footprint

```sh
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer\
  --namespace kubecost --create-namespace \
  -f values-secondary.yaml
```

### Cloud Cost Reconciliation

It is recommended to get Kubecost up and running before configuring cloud-integrations.

Without cloud-integrations, Kubecost will use public onDemand rates for each cloud provider. In order to reconcile the short-term onDemand costs with actual cloud billing, configure the following:

- [AWS cloud-integration](https://github.com/kubecost/docs/blob/main/aws-out-of-cluster.md)
- [Azure cloud-integration](https://github.com/kubecost/docs/blob/main/azure-out-of-cluster.md)
- [GCP cloud-integration](https://github.com/kubecost/docs/blob/main/gcp-out-of-cluster.md)

During a POC, these secrets can be entered in the Kubecost UI in the `Settings` page under `Cloud Cost Settings`.

Long-term, Kubecost recommends storing the configuration in `cloud-integration.json` that is described in the respective folders in this repo.

- [AWS](../aws/)
- [Azure](../azure/)
- [GCP](../gcp/)

## List of Metrics

You can run the following Prometheus query to list all of the metrics emitted by a given job:

```sh
group by(__name__) ({__name__!="", job="kubecost"})
```

```yaml
container_cpu_allocation
container_gpu_allocation
container_memory_allocation_bytes
deployment_match_labels
go_gc_duration_seconds
go_gc_duration_seconds_count
go_gc_duration_seconds_sum
go_goroutines
go_info
go_memstats_alloc_bytes
go_memstats_alloc_bytes_total
go_memstats_buck_hash_sys_bytes
go_memstats_frees_total
go_memstats_gc_sys_bytes
go_memstats_heap_alloc_bytes
go_memstats_heap_idle_bytes
go_memstats_heap_inuse_bytes
go_memstats_heap_objects
go_memstats_heap_released_bytes
go_memstats_heap_sys_bytes
go_memstats_last_gc_time_seconds
go_memstats_lookups_total
go_memstats_mallocs_total
go_memstats_mcache_inuse_bytes
go_memstats_mcache_sys_bytes
go_memstats_mspan_inuse_bytes
go_memstats_mspan_sys_bytes
go_memstats_next_gc_bytes
go_memstats_other_sys_bytes
go_memstats_stack_inuse_bytes
go_memstats_stack_sys_bytes
go_memstats_sys_bytes
go_threads
kube_namespace_labels
kube_node_labels
kube_node_status_allocatable
kube_node_status_allocatable_cpu_cores
kube_node_status_allocatable_memory_bytes
kube_node_status_capacity
kube_node_status_capacity_cpu_cores
kube_node_status_capacity_memory_bytes
kube_persistentvolume_capacity_bytes
kube_persistentvolumeclaim_info
kube_persistentvolumeclaim_resource_requests_storage_bytes
kube_pod_container_resource_requests
kube_pod_container_status_running
kube_pod_labels
kube_pod_owner
kubecost_allocation_data_status
kubecost_asset_data_status
kubecost_cluster_info
kubecost_cluster_management_cost
kubecost_etl_events_total
kubecost_etl_progress_percent
kubecost_http_requests_total
kubecost_http_response_size_bytes_count
kubecost_http_response_size_bytes_sum
kubecost_http_response_time_seconds_bucket
kubecost_http_response_time_seconds_count
kubecost_http_response_time_seconds_sum
kubecost_load_balancer_cost
kubecost_network_internet_egress_cost
kubecost_network_region_egress_cost
kubecost_network_zone_egress_cost
kubecost_node_is_spot
kubecost_pv_info
node_cpu_hourly_cost
node_gpu_count
node_gpu_hourly_cost
node_ram_hourly_cost
node_total_hourly_cost
opencost_build_info
pod_pvc_allocation
process_cpu_seconds_total
process_max_fds
process_open_fds
process_resident_memory_bytes
process_start_time_seconds
process_virtual_memory_bytes
process_virtual_memory_max_bytes
promhttp_metric_handler_requests_in_flight
promhttp_metric_handler_requests_total
pv_hourly_cost
scrape_duration_seconds
scrape_samples_post_metric_relabeling
scrape_samples_scraped
scrape_series_added
service_selector_labels
statefulSet_match_labels
```

And if you have the networkCosts daemonset:

```sh
group by(__name__) ({__name__!="", job="kubecost-networking"})
```

```yaml
kubecost_pod_network_egress_bytes_total
kubecost_pod_network_ingress_bytes_total
scrape_duration_seconds
scrape_samples_post_metric_relabeling
scrape_samples_scraped
scrape_series_added
```
