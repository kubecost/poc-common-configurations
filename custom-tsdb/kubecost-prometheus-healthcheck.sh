#!/bin/bash

# set HOST_NAME to prometheus endpoint.
# there is a false negative test, if you don't see "FALSE_NEGATIVE" in the the OPTIONAL_METRICS, script output is invalid.
# some metrics are optional: kubecost_pod_network*/GPU metrics/container_fs

export HOST_NAME="http://localhost:9090"

check_metric()
{
if  curl -s --data-urlencode "query=absent_over_time($1[5m])" "$HOST_NAME/api/v1/query"  |jq -r '.data.result[].value[]' --exit-status > /dev/null  ; then
 echo $1
fi
}

REQUIRED_METRICS=('container_cpu_allocation
container_cpu_usage_seconds_total
kube_node_status_allocatable
kube_node_status_allocatable_cpu_cores
kube_node_status_allocatable_memory_bytes
kube_node_status_capacity
kube_node_status_capacity_cpu_cores
kube_node_status_capacity_memory_bytes
kube_pod_container_resource_requests
kube_pod_container_status_running
node_cpu_hourly_cost
node_ram_hourly_cost
node_total_hourly_cost')

OPTIONAL_METRICS=('FALSE_NEGATIVE
container_fs_limit_bytes
container_fs_usage_bytes
container_gpu_allocation
container_memory_allocation_bytes
container_memory_working_set_bytes
container_network_receive_bytes_total
container_network_transmit_bytes_total
deployment_match_labels
kube_namespace_annotations
kube_namespace_labels
kube_node_labels
kube_node_status_condition
kube_persistentvolume_capacity_bytes
kube_persistentvolumeclaim_info
kube_persistentvolumeclaim_resource_requests_storage_bytes
kube_pod_annotations
kube_pod_labels
kube_pod_owner
kube_replicaset_owner
kubecost_allocation_data_status
kubecost_asset_data_status
kubecost_cluster_info
kubecost_cluster_management_cost
kubecost_etl_events_total
kubecost_etl_progress_percent
kubecost_load_balancer_cost
kubecost_network_internet_egress_cost
kubecost_network_region_egress_cost
kubecost_network_zone_egress_cost
kubecost_node_is_spot
kubecost_pod_network_egress_bytes_total
kubecost_pod_network_ingress_bytes_total
kubecost_pv_info
kubelet_volume_stats_used_bytes
node_cpu_seconds_total
node_gpu_count
node_gpu_hourly_cost
pod_pvc_allocation
process_cpu_seconds_total
process_max_fds
process_open_fds
process_resident_memory_bytes
process_start_time_seconds
process_virtual_memory_bytes
process_virtual_memory_max_bytes
pv_hourly_cost
service_selector_labels
statefulSet_match_labels')

echo "REQUIRED_METRICS Missing:"
for str in ${REQUIRED_METRICS[@]}; do
check_metric $str
done

echo "OPTIONAL_METRICS Missing:"
for str in ${OPTIONAL_METRICS[@]}; do
check_metric $str
done