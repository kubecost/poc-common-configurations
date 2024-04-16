variable "license" {
  description = "Kubecost license key"
  sensitive   = true
}

variable "primary_cluster" {
  description = "A flag indicating whether we are running Terraform on a primary cluster. The secondary clusters push their metrics to a central bucket. The primary cluster aggregates all metrics and displays them in the frontend."
  default     = false
}

variable "federated_storage_bucket" {
  type        = string
  description = "Name of the bucket in the primary account which stores federated metrics data. All clusters push to this bucket. This module will create the bucket"
}

variable "primary_s3_bucket_region" {
  description = "Specify the region the federated storage bucket is in"
}

variable "athena_storage_bucket" {
  type        = string
  description = "Name of the bucket in the primary account which stores athena query results. This module will create the bucket"
}

variable "cur_bucket_name" {
  type        = string
  description = "Name of the cur bucket"
  default     = "kubecost_cur"
}

variable "tags" {
  type        = map(string)
  description = "Default tags applied to all AWS resources"
  default     = {}
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

variable "cluster_id" {
  description = "Name for the EKS clutser - e.g. dev, staging"
}

# TODO: Currently only supports one argument. Needs to support a list of AWS accounts.
variable "secondary_account_number" {
  description = "AWS account number where your secondary clusters may be running"
  default     = "11111111"
}

variable "kubecost_helm_release_name" {
  description = "Use it to customize release name"
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
  default     = ""
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
}

variable "saml_idp_metadata_url" {
  description = "idpMetadataURL"
  type        = string
}

variable "saml_app_root_url" {
  description = "appRootURL"
  type        = string
}
