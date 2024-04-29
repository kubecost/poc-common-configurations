variable "tags" {
  description = "Default tags applied to all AWS resources"
  type        = map(string)
  default     = {}
}

variable "kubecost_non_helm_k8s_labels" {
  type    = map(string)
  default = {}
}

### Primary Cluster variables

variable "license" {
  description = "Kubecost license key"
  sensitive   = true
}

variable "primary_cluster" {
  description = "A flag indicating whether we are running Terraform on a primary cluster. The secondary clusters push their metrics to a central bucket. The primary cluster aggregates all metrics and displays them in the frontend."
  default     = false
}

variable "federated_storage_bucket_name" {
  description = "Name of the bucket in the primary account which stores federated metrics data. All clusters push to this bucket. This module will create the bucket"
  type        = string
}

variable "federated_storage_bucket_region" {
  description = "Specify the region the federated storage bucket is in"
}

variable "secondary_account_numbers" {
  description = "AWS account number where your secondary clusters may be running, only needed in primary, this is to add to federated_storage_bucket s3 policy"
  type        = list(string)
  default     = ["1221", "23432423", "234234324"]
}

variable "athena_storage_bucket_name" {
  description = "Name of the bucket in the primary account which stores athena query results. This module will create the bucket"
  type        = string
  default     = "athena_not_needed_in_secondary_account"
}

variable "force_destroy_s3_buckets" {
  description = "Should terraform force destroy buckets that this module created on terraform destroy"
  default     = false
}

variable "federated_storage_days" {
  description = "How many days federated storage s3 bucket should store federated data"
  default     = 365
}

variable "athena_storage_days" {
  description = "How many days athena storage s3 bucket should store query results"
  default     = 365
}

### Cur variables needed in the primary account

variable "cur_bucket_name" {
  description = "Name of the cur bucket"
  type        = string
  default     = "kubecost_cur"
}

variable "cur_prefix" {
  description = "AWS report prefix, depends on how cur is generated"
  default     = ""
}

variable "cur_cost_and_usage_data_status_path" {
  description = "AWS S3 bucket path to cost and usage data status"
  type        = string
  default     = ""
}

variable "kubecost_cloud_formation_stack_name" {
  description = "Use it to customize cloudformation stack name for reading CUR data"
  default     = "kubecost"
}

variable "kubecost_aggregator_bucket_refresh_interval" {
  description = "how long the Aggregator spends ingesting ETL datafrom the federated store bucket into SQL tables"
  default     = "2h"
}

variable "kubecost_aggregator_db_storage_days" {
  description = "how much data to keep in the DB before rolling the data off"
  default     = "365"
}

variable "kubecost_aggregator_db_memory_limit" {
  description = "Maximum memory DB read process should use"
  default     = "8GB"
}

variable "kubecost_aggregator_db_write_memory_limit" {
  description = "Maximum memory DB write process should use"
  default     = "8GB"
}

variable "kubecost_aggregator_db_read_threads" {
  description = "how many threads the DB read process to run"
  default     = "3"
}

variable "kubecost_aggregator_db_write_threads" {
  description = "how many threads the DB write process to run"
  default     = "3"
}

### Helm variables in primary and secondary clusters

variable "cluster_id" {
  description = "Name for the EKS clutser - e.g. dev, staging"
}

variable "kubecost_helm_release_name" {
  description = "Use it to customize release name"
  default     = "kubecost"
}

variable "kubecost_version" {
  description = "Kubecost helm chart version"
  type        = string
  default     = "2.2.0"
}

variable "namespace" {
  description = "Namespace where Kubecost resources are deployed in the cluster"
  type        = string
  default     = "kubecost"
}

variable "helm_postrender_script_path" {
  description = "Specify a script that runs after the Kubecost Helm release is rendered. Typically used for adding labels to all k8s resources."
  default     = ""
}

variable "helm_postrender_script_args" {
  description = "Arguments for the postrender script"
  default     = ""
}

variable "helm_values_overrides_path" {
  description = "Path to the values overrides for kubecost"
  default     = "overrides.yaml"
}

### SAML

variable "saml_enabled" {
  description = "Enable SAML"
  default     = false
}

variable "saml_secret" {
  description = "SAML certificate"
  sensitive   = true
  type        = string
  default     = ""
}

variable "saml_idp_metadata_url" {
  description = "idpMetadataURL"
  type        = string
  default     = ""
}

variable "saml_app_root_url" {
  description = "appRootURL"
  type        = string
  default     = ""
}


# Kubernetes resource requests/limits

#kubecostFrontend
variable "kubecost_frontend_cpu_request" {
  description = "CPU request for frontend deployment"
  default     = "10m"
}

variable "kubecost_frontend_memory_request" {
  description = "Memory request for frontend deployment"
  default     = "55Mi"
}

variable "kubecost_frontend_cpu_limit" {
  description = "CPU limit for frontend deployment"
  default     = "100m"
}

variable "kubecost_frontend_memory_limit" {
  description = "Memory limit for frontend deployment"
  default     = "256Mi"
}

#kubecostModel
variable "kubecost_model_cpu_request" {
  description = "CPU request for model deployment"
  default     = "200m"
}

variable "kubecost_model_memory_request" {
  description = "Memory request for model deployment"
  default     = "55Mi"
}

variable "kubecost_model_cpu_limit" {
  description = "CPU limit for model deployment"
  default     = "1"
}

variable "kubecost_model_memory_limit" {
  description = "Memory limit for model deployment"
  default     = "256Mi"
}

#kubecostAggregator

variable "kubecost_aggregator_cpu_request" {
  description = "CPU request for aggregator deployment"
  default     = "1"
}

variable "kubecost_aggregator_memory_request" {
  description = "Memory request for aggregator deployment"
  default     = "1Gi"
}

variable "kubecost_aggregator_cpu_limit" {
  description = "CPU limit for aggregator deployment"
  default     = "1"
}

variable "kubecost_aggregator_memory_limit" {
  description = "Memory limit for aggregator deployment"
  default     = "1Gi"
}

#kubecostaggregator_cloudcost

variable "kubecost_aggregator_cloudcost_cpu_request" {
  description = "CPU request for aggregator cloudcost deployment"
  default     = "1"
}

variable "kubecost_aggregator_cloudcost_memory_request" {
  description = "Memory request for aggregator cloudcost deployment"
  default     = "1Gi"
}

variable "kubecost_aggregator_cloudcost_cpu_limit" {
  description = "CPU limit for aggregator cloudcost deployment"
  default     = "1"
}

variable "kubecost_aggregator_cloudcost_memory_limit" {
  description = "Memory limit for aggregator cloudcost deployment"
  default     = "1Gi"
}

# prometheus
variable "kubecost_prometheus_server_cpu_limit" {
  description = "CPU limit for kubecost-prometheus-server deployment"
  default     = "500m"
}

variable "kubecost_prometheus_server_memory_limit" {
  description = "Memory limit for kubecost-prometheus-server deployment"
  default     = "2Gi"
}

variable "kubecost_prometheus_server_cpu_request" {
  description = "CPU request for kubecost-prometheus-server deployment"
  default     = "500m"
}

variable "kubecost_prometheus_server_memory_request" {
  description = "Memory request for kubecost-prometheus-server deployment"
  default     = "1Gi"
}

#networkCosts

variable "kubecost_network_cost_cpu_limit" {
  description = "CPU request for network deployment"
  default     = "500m"
}

variable "kubecost_network_cost_memory_limit" {
  description = "Memory request for network deployment"
  default     = "4Gi"
}

variable "kubecost_network_cost_cpu_request" {
  description = "CPU limit for network deployment"
  default     = "50m"
}

variable "kubecost_network_cost_memory_request" {
  description = "Memory limit for network deployment"
  default     = "20Mi"
}

#Kubernetes pvc sizes

variable "cost_analyzer_pvc_size" {
  description = "PVC size for cost analyzer"
  default     = "32Gi"
}

variable "cost_analyzer_db_size" {
  description = "DB size for cost analyzer"
  default     = "32.0Gi"
}

variable "kubecost_prometheus_server_pvc_size" {
  description = "Size of kubecost-prometheus-server PVC"
  default     = "32Gi"
}


# features -  Anomalies, network cost, cluster controller, datadog external costs

variable "networkcost_enabled" {
  description = "Enable network cost"
  default     = false
}

variable "forecast_enabled" {
  description = "Enable forecasting ML"
  default     = true
}