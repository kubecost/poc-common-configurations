#Create namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.kubecost_namespace
  }
}

# Create kubecost release and deploy cost-analyzer charts
resource "helm_release" "kubecost" {
  chart      = "cost-analyzer"
  name       = "kubecost"
  namespace  = var.kubecost_namespace
  repository = var.kubecost_repo

# Uncomment lines below to point at local copy of values.yaml file.  This terraform is setup by default to use kubecost packages values.yaml

#  values = [
#    "${file("values.yaml")}"
#  ]


# Uncomment line below if you wish to use a specific version.  Change the version in terraform.tfvars

#  version    = var.kubecost_chart_version

# Uncomment lines below to set additional helm values not defined in your values.yaml

#    set {
#    name  = "prometheus.server.persistentVolume.enabled"
#    value = true
#  }
}