resource "helm_release" "kubecost_core_secondary" {
  count = var.primary_cluster ? 0 : 1

  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = var.kubecost_version
  namespace  = var.namespace

  values = [
    <<EOF
global:
  grafana:
    enabled: false
    proxy: false
kubecostProductConfigs:
  clusterName: ${var.cluster_id}
prometheus:
  server:
    global:
      external_labels:
        cluster_id: ${var.cluster_id}
forecasting:
  enabled: false

    EOF
  ]
}