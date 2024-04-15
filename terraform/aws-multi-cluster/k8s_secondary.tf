# K8s resources for Kubecost secondary cluster defined here. Secondary clusters are responsible for monitoring, processing metrics into ETL data, then pushing ETL data to the central storage bucket.

resource "helm_release" "kubecost_core_secondary" {
  count = var.primary_cluster ? 0 : 1

  name       = var.kubecost_helm_release_name
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = var.kubecost_version
  namespace  = var.namespace

  postrender {
    binary_path = var.helm_postrender_script_path
    args        = [var.helm_postrender_script_args]
  }

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
federatedETL:
  agentOnly: true
kubecostModel:
  federatedStorageConfigSecret: federated-store
serviceAccount:
  annotations:
    "eks.amazonaws.com/role-arn": ${aws_iam_role.kubecost_federated_storage.arn}
    EOF
,
fileexists("${var.helm_values_overrides_path}") ? file("${var.helm_values_overrides_path}") : ""

  ]
}
