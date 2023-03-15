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

myArray=('test1
avg(kube_pod_container_status_running{})by(pod,namespace)
avg(kube_pod_container_status_running{})by(pod,namespace,uid)
avg(avg_over_time(container_memory_allocation_bytes{container!="",container!="POD",node!=""}[5m]))by(container,pod,namespace,node,provider_id)
avg(avg_over_time(kube_pod_container_resource_requests{resource="memory",unit="byte",container!="",container!="POD",node!=""}[5m]))by(container,pod,namespace,node)
avg(avg_over_time(container_memory_working_set_bytes{container!="",container_name!="POD",container!="POD"}[5m]))by(container_name,container,pod_name,pod,namespace,instance)
max(max_over_time(container_memory_working_set_bytes{container!="",container_name!="POD",container!="POD"}[5m]))by(container_name,container,pod_name,pod,namespace,instance)
avg(avg_over_time(container_cpu_allocation{container!="",container!="POD",node!=""}[5m]))by(container,pod,namespace,node)
avg(avg_over_time(kube_pod_container_resource_requests{resource="cpu",unit="core",container!="",container!="POD",node!=""}[5m]))by(container,pod,namespace,node)
avg(rate(container_cpu_usage_seconds_total{container!="",container_name!="POD",container!="POD"}[5m]))by(container_name,container,pod_name,pod,namespace,instance)
max(rate(container_cpu_usage_seconds_total{container!="",container_name!="POD",container!="POD"}[5m]))by(container_name,container,pod_name,pod,namespace,instance)
avg(avg_over_time(container_gpu_allocation{container!="",container!="POD",node!=""}[5m]))by(container,pod,namespace,node)
avg(avg_over_time(node_cpu_hourly_cost[5m]))by(node,instance_type,provider_id)
avg(avg_over_time(node_ram_hourly_cost[5m]))by(node,instance_type,provider_id)
avg(avg_over_time(node_gpu_hourly_cost[5m]))by(node,instance_type,provider_id)
avg_over_time(kubecost_node_is_spot[5m])
avg(kube_persistentvolumeclaim_info{volumename!=""})by(persistentvolumeclaim,storageclass,volumename,namespace)
avg(avg_over_time(pod_pvc_allocation[5m]))by(persistentvolume,persistentvolumeclaim,pod,namespace)
avg(avg_over_time(kube_persistentvolumeclaim_resource_requests_storage_bytes{}[5m]))by(persistentvolumeclaim,namespace)
count(kube_persistentvolume_capacity_bytes)by(persistentvolume)
avg(avg_over_time(kube_persistentvolume_capacity_bytes[5m]))by(persistentvolume)
avg(avg_over_time(pv_hourly_cost[5m]))by(volumename)
avg(avg_over_time(kubecost_network_zone_egress_cost{}[5m]))
avg(avg_over_time(kubecost_network_region_egress_cost{}[5m]))
avg(avg_over_time(kubecost_network_internet_egress_cost{}[5m]))
sum(increase(container_network_receive_bytes_total{pod!=""}[5m]))by(pod_name,pod,namespace)
sum(increase(container_network_transmit_bytes_total{pod!=""}[5m]))by(pod_name,pod,namespace)
avg_over_time(kube_node_labels[5m])
avg_over_time(kube_namespace_labels[5m])
avg_over_time(kube_namespace_annotations[5m])
avg_over_time(kube_pod_labels[5m])
avg_over_time(kube_pod_annotations[5m])
avg_over_time(service_selector_labels[5m])
avg_over_time(deployment_match_labels[5m])
sum(avg_over_time(kube_pod_owner{owner_kind="DaemonSet"}[5m]))by(pod,owner_name,namespace)
sum(avg_over_time(kube_pod_owner{owner_kind="ReplicaSet"}[5m]))by(pod,owner_name,namespace)
kube_node_status_capacity
kube_node_status_capacity_memory_bytes
kube_node_status_capacity_cpu_cores
kube_node_status_allocatable
kube_node_status_allocatable_memory_bytes
kube_node_status_allocatable_cpu_cores
kube_node_labels
kube_node_status_condition
kube_namespace_labels
kube_pod_labels
kube_pod_owner')

for str in ${myArray[@]}; do
check_metric $str
done