#!/bin/bash

# set HOST_NAME to prometheus endpoint.
# there is a false negative test, if you don't see "FALSE_NEGATIVE" in the the OPTIONAL_METRICS, script output is invalid.
# some metrics are optional: kubecost_pod_network*/GPU metrics/container_fs
# metrics are expoesed on cost-model container :9003/metrics
# show all kubecost metrics in grafana: topk(1000, count by (__name__)({__name__=~".+",job="kubecost"}))

# HOST_NAME=$KUBECOST_SERVICE
OUTPUT_LABELS="true"
HOST_NAME="http://localhost:9090/model/prometheusQuery"

check_metric_missing()
{

if  curl -sG --data-urlencode "query=absent_over_time($1[2m])" "$HOST_NAME"  |jq -r '.data.result[].value[]' --exit-status > /dev/null  ; then
echo "Missing: $1"
fi
# curl -sG --data-urlencode "query=absent_over_time($1[5m])" "$HOST_NAME"  |jq -r '.data.result[].value[]'
}

check_metric_labels()
{
echo $1 $(curl -sG --data-urlencode "query=topk(1,$1)" "$HOST_NAME")
}

REQUIRED_METRICS=('container_cpu_allocation
container_cpu_cfs_throttled_periods_total
container_cpu_usage_seconds_total
container_fs_limit_bytes
container_fs_usage_bytes
container_gpu_allocation
container_memory_allocation_bytes
container_memory_working_set_bytes
container_network_receive_bytes_total
container_network_transmit_bytes_total
deployment_match_labels
kube_namespace_labels
kube_node_labels
kube_node_status_allocatable_cpu_cores
kube_node_status_allocatable_memory_bytes
kube_node_status_capacity_cpu_cores
kube_node_status_capacity_memory_bytes
kube_persistentvolume_capacity_bytes
kube_persistentvolumeclaim_info
kube_persistentvolumeclaim_resource_requests_storage_bytes
kube_pod_container_resource_requests
kube_pod_container_status_running
kube_pod_container_status_terminated_reason
kube_pod_labels
kube_pod_owner
kube_pod_status_phase
kube_replicaset_owner
kubecost_allocation_data_status
kubecost_asset_data_status
kubecost_cluster_info
kubecost_cluster_management_cost
kubecost_container_cpu_usage_irate
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
pod_pvc_allocation
pv_hourly_cost
service_selector_labels
statefulSet_match_labels')

OPTIONAL_METRICS=('false_positive
kube_namespace_annotations
kube_pod_annotations
kubecost_pod_network_egress_bytes_total
kubelet_volume_stats_used_bytes
node_cpu_seconds_total
node_memory_MemTotal_bytes
prometheus_target_interval_length_seconds')

# The pod script runs in a loop, but this standalone script does not.
# while true; do

    echo "------------Starting_Missing_Metrics_Check--------------"
    echo "Host: $HOST_NAME"
    echo "REQUIRED_METRICS Missing:"
    for str in ${REQUIRED_METRICS[@]}; do
    check_metric_missing $str
    done

    echo "OPTIONAL_METRICS Missing:"
    for str in ${OPTIONAL_METRICS[@]}; do
    check_metric_missing $str
    done

    if [[ "$OUTPUT_LABELS" ]]; then
        echo "Label Check:"
        for str in ${REQUIRED_METRICS[@]}; do
        check_metric_labels $str
        done
    fi

#     echo "-----------Sleeping 600 seconds----------"
#     sleep 600
# done