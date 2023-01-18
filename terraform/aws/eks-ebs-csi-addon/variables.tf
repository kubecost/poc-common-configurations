variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_name" {
  type = string
  default = "example-vpc"
}

variable "cluster_name" {
  type = string
  default = "example-cluster"
}

variable "cluster_version" {
  type = string
  default = "1.23"
}

variable "node_group_one_name" {
  type = string
  default = "ng-example-1"
}

#variable "node_group_two_name" {
# type = string
#  default = "ng-example-2"
#}

variable "instance_type_one" {
  type = string
  default = "t3.small"
}

#variable "instance_type_two" {
#  type = string
#  default = "t3.small"
#}