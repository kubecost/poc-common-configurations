# Kubecost with existing multi-cluster aggregated metrics

Note that the most common support issue with Kubecost is due to misconfigured Prometheus. Kubecost has a turnkey solution for multi-cluster and the below configuration should only be used by advanced Kubernetes teams.

This repo is intended for use during a POC with assistance from the Solutions Engineering team.

It is recommended to run Kubecost with default settings during proof-of-concepts in order to reduce issues.

Before disabling Kubecost prometheus, multi-cluster metric aggregation must be reliable and include per-cluster labels.

 > Multi-cluster requires an enterprise subscription


## Installation

In addition to the settings below, each cluster must scrape the kubecost exporter.

To scrape the Kubecost exporter, either use Kubecost serviceMonitor (in the yaml config for both primary and secondaries) or see [extraScrapeConfigs.yaml](extraScrapeConfigs.yaml).

Negative idle costs are almost always a result of missing these metrics.

### Primary cluster install:

```sh
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f values-primary.yaml
```

### Secondary clusters run a minimal footprint.

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

```
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
kube_node_status_allocatable_cpu_cores
kube_node_status_allocatable_memory_bytes
kube_node_status_capacity_cpu_cores
kube_node_status_capacity_memory_bytes
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