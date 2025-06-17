# K8s resources for Kubecost secondary cluster defined here. Secondary clusters are responsible for monitoring, processing metrics into ETL data, then pushing ETL data to the central storage bucket.

resource "helm_release" "kubecost_core_secondary" {
  count = var.primary_cluster ? 0 : 1

  name       = var.kubecost_helm_release_name
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "kubecost"
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
    persistentVolume:
      size: "${var.kubecost_prometheus_server_pvc_size}"
    resources:
      limits:
        cpu: "${var.kubecost_prometheus_server_cpu_limit}"
        memory: "${var.kubecost_prometheus_server_memory_limit}"
      requests:
        cpu: "${var.kubecost_prometheus_server_cpu_request}"
        memory: "${var.kubecost_prometheus_server_memory_request}"
forecasting:
  enabled: ${var.forecast_enabled}
federatedETL:
  agentOnly: true
kubecostModel:
  federatedStorageConfigSecret: federated-store
  resources:
    requests:
      cpu: "${var.kubecost_model_cpu_request}"
      memory: "${var.kubecost_model_memory_request}"
    limits:
      cpu: "${var.kubecost_model_cpu_limit}"
      memory: "${var.kubecost_model_memory_limit}"
networkCosts:
  enabled: ${var.networkcost_enabled}
  config:
    services:
      amazon-web-services: true
  resources:
      limits:
          cpu: "${var.kubecost_network_cost_cpu_limit}"
          memory: "${var.kubecost_network_cost_memory_limit}"
      requests:
          cpu: "${var.kubecost_network_cost_cpu_request}"
          memory: "${var.kubecost_network_cost_memory_request}"
persistentVolume:
  size: "${var.cost_analyzer_pvc_size}"
  dbSize: "${var.cost_analyzer_db_size}"
serviceAccount:
  annotations:
    "eks.amazonaws.com/role-arn": ${aws_iam_role.kubecost_federated_storage.arn}
    EOF
    ,
    fileexists("${var.helm_values_overrides_path}") ? file("${var.helm_values_overrides_path}") : ""
  ]
  depends_on = [
    kubernetes_secret.federated_store
  ]
}
