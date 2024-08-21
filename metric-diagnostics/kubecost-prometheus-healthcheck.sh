#!/bin/bash

# set KUBECOST_HOST_NAME to the Kubecost fqdn, including the path to the frontend api service
# For example, if you port forward kubecost:
# kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090
# then set the KUBECOST_HOST_NAME:
# export KUBECOST_HOST_NAME="http://localhost:9090/model/prometheusQuery"
# If using kubecost with SSO, port forward to the cost-model service:
# kubectl port-forward -n kubecost svc/kubecost-cost-model 9007
# then set the KUBECOST_HOST_NAME:
# export KUBECOST_HOST_NAME="http://localhost:9007/prometheusQuery"

# some metrics are optional: kubecost_pod_network*/GPU metrics/annotations

# sample query to show all kubecost metrics in grafana:
# topk(1000, count by (__name__)({__name__=~".+",job="kubecost"}))

if [[ -z $OUTPUT_LABELS ]]; then OUTPUT_LABELS="false"; fi
if [[ -z $CHECK_LABELS ]]; then CHECK_LABELS="false"; fi
if [[ -z $MULTI_CLUSTER ]]; then MULTI_CLUSTER="false" ; fi
if [[ -z $RUN_IN_POD ]]; then RUN_IN_POD="false" ; fi
if [[ -z $KUBECOST_SERVICE ]]; then HOST_NAME="$KUBECOST_SERVICE" ; fi


# TODO: fix multi-cluster (only needed for AMP/Mimir/GMP/etc)
if ${MULTI_CLUSTER}; then
    if [[ -z $PROM_CLUSTERID_LABEL ]]; then echo "The env varaible for PROM_CLUSTERID_LABEL must be set" && exit 1 ; fi
    if [[ -z $CLUSTER_NAME ]]; then echo "The env varaible for CLUSTER_NAME must be set" && exit 1 ; fi

    CLUSTER_FILTER="{$PROM_CLUSTERID_LABEL=\"$CLUSTER_NAME\"}"
fi

check_metric_missing()
{
# echo curl -G --data-urlencode "query=absent_over_time($1$CLUSTER_FILTER[2m])" "$HOST_NAME"
# curl -G --data-urlencode "query=absent_over_time($1$CLUSTER_FILTER[2m])" "$HOST_NAME"
# exit
    if  curl -sG --data-urlencode "query=absent_over_time($1[2m])" "$HOST_NAME"  |jq -r '.data.result[].value[]' --exit-status > /dev/null  ; then

        if [[ $1 = "false_negative" ]]; then
            FALSE_NEGATIVE="pass"
            echo "Prometheus query endpoint is working"
        else
            echo "Missing: $1"
        fi
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
kube_pod_labels
kube_pod_owner
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

OPTIONAL_METRICS=('kube_namespace_annotations
kube_pod_annotations
kubecost_pod_network_egress_bytes_total
kubelet_volume_stats_used_bytes
node_cpu_seconds_total
node_memory_MemTotal_bytes
prometheus_target_interval_length_seconds')

if [[ -z $HOST_NAME ]]; then
    HOST_NAME="${KUBECOST_HOST_NAME}"
fi
if [[ -z $HOST_NAME ]]; then
    echo "KUBECOST_HOST_NAME is not set"
    exit 1
fi

if [[ $HOST_NAME != http?(s)://* ]]; then
    echo "HOST_NAME must start with http:// or https://"
    exit 1
fi


run_checks()
{
    echo "------------Starting_Missing_Metrics_Check--------------"
    echo "Host: $HOST_NAME"

    FALSE_NEGATIVE="fail"
    check_metric_missing "false_negative"
    if [[ $FALSE_NEGATIVE = "fail" ]]; then
        echo "Please check if the prometheus query endpoint is working"
        exit 1
    fi

    echo "REQUIRED_METRICS Missing:"
    for str in ${REQUIRED_METRICS[@]}; do
    check_metric_missing $str
    done


    echo "OPTIONAL_METRICS Missing:"
    for str in ${OPTIONAL_METRICS[@]}; do
    check_metric_missing $str
    done

    if [[ "$OUTPUT_LABELS" = "true" ]]; then
        echo "Label Check:"
        for str in ${REQUIRED_METRICS[@]}; do
        check_metric_labels $str
        done
    fi
}

run_checks

if [[ "$RUN_IN_POD" = "true" ]]; then
    echo "Running in pod mode"
    sleep 600
    while true; do

        run_checks
        echo "-----------Sleeping 600 seconds----------"
        sleep 600
    done
fi
