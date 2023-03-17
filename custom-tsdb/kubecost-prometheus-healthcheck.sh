#!/bin/bash

# set HOST_NAME to prometheus endpoint.
# if you don't see "missing missing" the script output is invalid.

export HOST_NAME="http://localhost:9090"

check_metric()
{
if  ! curl -s --data-urlencode "query=$1" "$HOST_NAME/api/v1/query"  |jq -r '.data.result[].value[]' --exit-status > /dev/null  ; then
 echo "missing" $1
fi
}

myArray=('missing
container_cpu_allocation
container_gpu_allocation
container_memory_allocation_bytes
deployment_match_labels
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
statefulSet_match_labels
')

for str in ${myArray[@]}; do
check_metric $str
done