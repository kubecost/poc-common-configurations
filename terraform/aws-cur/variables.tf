variable "tags" {
  description = "Default tags to always apply"
  type        = map(string)
}

variable "cur_bucket" {
  description = "AWS bucket containing CUR report"
}

variable "cur_prefix" {
  description = "AWS report prefix"
}

variable "kubecost_user" {
  description = "IAM User used by Kubecost"
}

variable "cur_cost_and_usage_data_status_path" {
  description = "AWS S3 bucket path to cost and usage data status"
  type        = string
}
