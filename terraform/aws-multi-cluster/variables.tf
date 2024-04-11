variable "license" {
  description = "Kubecost license key"
  sensitive   = true
}

variable "primary_cluster" {
  description = "Primary Cluster to consolidate all secondary Clusters Metrics Data and primary's data. Secondary clusters sends metrics data to the primary cluster"
  default     = false
}

variable "federated_storage_bucket" {
  type        = string
  description = "Name of the bucket in the primary account which stores federated metrics data. All clusters push to this bucket. This module will create the bucket"
}

variable "tags" {
  type        = map(string)
  description = "default tags applied to all AWS resources"
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
  description = "Name for the EKS clutser - e.g. dev,staging"
}

variable "secondary_account_number" {
  description = "AWS Account number"
  default     = "11111111"
}

variable "kubecost_helm_release_name" {
  description = "Use it to customize release name"
  default = "kubecost"
}

variable "primary_s3_bukcet_region" {
  description = "Use it to customize release name"
}