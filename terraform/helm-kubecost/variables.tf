variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}

variable "kubecost_namespace" {
  type    = string
  default = "kubecost"
}

variable "kubecost_repo" {
  type = string
  default = "https://kubecost.github.io/cost-analyzer/"
}

variable "kubecost_chart_version" {
  type = string
  default = "1.99.0"
}
