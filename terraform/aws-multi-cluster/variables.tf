variable "tags" {
  description = "Default tags applied to all AWS resources"
  type        = map(string)
  default     = {}
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
}

variable "force_destroy_s3_buckets" {
  description = "Should terraform force destroy buckets that this module created on terraform destroy"
  default     = false
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

# TODO: Currently only supports one argument
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
