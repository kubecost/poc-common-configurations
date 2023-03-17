#!/bin/bash

# set hostname to prometheus endpoint.
# if you don't see "missing test1" the script output is invalid.

export HOST_NAME="http://localhost:9090"

check_metric()
{
if  ! curl -s --data-urlencode "query=$1" "$HOST_NAME/api/v1/query"  |jq -r '.data.result[].value[]' --exit-status > /dev/null  ; then
 echo "missing" $1
fi
}

myArray=('container_cpu_allocation
container_cpu_usage_seconds_total
container_gpu_allocation
container_memory_allocation_bytes
container_memory_working_set_bytes
container_network_receive_bytes_total
container_network_transmit_bytes_total
kube_namespace_labels
kube_node_labels
kube_node_status_allocatable
kube_node_status_allocatable_cpu_cores
kube_node_status_allocatable_memory_bytes
kube_node_status_capacity
kube_node_status_capacity_cpu_cores
kube_node_status_capacity_memory_bytes
kube_node_status_condition
kube_persistentvolume_capacity_bytes
kube_persistentvolumeclaim_resource_requests_storage_bytes
kube_pod_container_resource_requests
kube_pod_container_status_running
kube_pod_labels
kube_pod_owner
kubecost_network_internet_egress_cost
kubecost_network_region_egress_cost
kubecost_network_zone_egress_cost
kubecost_node_is_spot
node_cpu_hourly_cost
node_gpu_hourly_cost
node_ram_hourly_cost
pod_pvc_allocation
pv_hourly_cost
test1
')

for str in ${myArray[@]}; do
check_metric $str
done