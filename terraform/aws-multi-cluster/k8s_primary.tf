# K8s resources for Kubecost primary cluster defined here. The primary cluster aggregates all metrics from a central bucket and hosts the Kubecost frontend.

resource "helm_release" "kubecost_core_primary" {
  count = var.primary_cluster ? 1 : 0

  name       = var.kubecost_helm_release_name
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = var.kubecost_version
  namespace  = var.namespace

  postrender {
    binary_path = var.helm_postrender_script_path
    args        = [var.helm_postrender_script_args]
  }

  depends_on = [kubernetes_secret.kubecost_license, kubernetes_secret.kubecost_cloud_integration, kubernetes_secret.kubecost_saml_secret]

  values = [
    <<EOF
global:
  grafana:
    enabled: false
    proxy: false
kubecostProductConfigs:
  clusterName: ${var.cluster_id}
  productKey:
    enabled: true
    secretname: kubecost-license
  cloudIntegrationSecret: "cloud-integration"
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

kubecostAggregator:
  deployMethod: statefulset
  env:
    DB_BUCKET_REFRESH_INTERVAL: "${var.kubecost_aggregator_bucket_refresh_interval}"
    ETL_DAILY_STORE_DURATION_DAYS: "${var.kubecost_aggregator_db_storage_days}"
    DB_MEMORY_LIMIT: "${var.kubecost_aggregator_db_memory_limit}"
    DB_WRITE_MEMORY_LMIT: "${var.kubecost_aggregator_db_write_memory_limit}"
    DB_READ_THREADS: "${var.kubecost_aggregator_db_read_threads}"
    DB_WRITE_THREADS: "${var.kubecost_aggregator_db_write_threads}"
  resources:
    requests:
      cpu: "${var.kubecost_aggregator_cpu_request}"
      memory: "${var.kubecost_aggregator_memory_request}"
    limits:
      cpu: "${var.kubecost_aggregator_cpu_limit}"
      memory: "${var.kubecost_aggregator_memory_limit}"
  cloudCost:
    resources:
      requests:
        cpu: "${var.kubecost_aggregator_cloudcost_cpu_request}"
        memory: "${var.kubecost_aggregator_cloudcost_memory_request}"
      limits:
        cpu: "${var.kubecost_aggregator_cloudcost_cpu_limit}"
        memory: "${var.kubecost_aggregator_cloudcost_memory_limit}"

kubecostModel:
  federatedStorageConfigSecret: federated-store
  resources:
    requests:
      cpu: "${var.kubecost_model_cpu_request}"
      memory: "${var.kubecost_model_memory_request}"
    limits:
      cpu: "${var.kubecost_model_cpu_limit}"
      memory: "${var.kubecost_model_memory_limit}"
serviceAccount:
  annotations:
    "eks.amazonaws.com/role-arn": ${aws_iam_role.kubecost_federated_storage.arn}

kubecostFrontend:
  resources:
    requests:
      cpu: "${var.kubecost_frontend_cpu_request}"
      memory: "${var.kubecost_frontend_memory_request}"
    limits:
      cpu: "${var.kubecost_frontend_cpu_limit}"
      memory: "${var.kubecost_frontend_memory_limit}"

persistentVolume:
  size: "${var.cost_analyzer_pvc_size}"
  dbSize: "${var.cost_analyzer_db_size}"

networkCosts:
  enabled: ${var.networkcost_enabled}
  resources:
      limits:
          cpu: "${var.kubecost_network_cost_cpu_limit}"
          memory: "${var.kubecost_network_cost_memory_limit}"
      requests:
          cpu: "${var.kubecost_network_cost_cpu_request}"
          memory: "${var.kubecost_network_cost_memory_request}"

saml:
  enabled: ${var.saml_enabled}
  secretName: "kubecost-saml"
  idpMetadataURL: "${var.saml_idp_metadata_url}"
  appRootURL: "${var.saml_app_root_url}"
    EOF
    ,
    fileexists("${var.helm_values_overrides_path}") ? file("${var.helm_values_overrides_path}") : ""
  ]
}

resource "kubernetes_secret" "kubecost_license" {
  count = var.primary_cluster ? 1 : 0
  metadata {
    name      = "kubecost-license"
    namespace = var.namespace
    labels    = var.kubecost_non_helm_k8s_labels
  }

  data = {
    "productkey.json" = var.license
  }
}

resource "kubernetes_secret" "kubecost_cloud_integration" {
  count = var.primary_cluster ? 1 : 0
  metadata {
    name      = "cloud-integration"
    namespace = var.namespace
    labels    = var.kubecost_non_helm_k8s_labels
  }

  data = {
    "cloud-integration.json" = <<EOF
{
    "aws": [
        {
            "athenaBucketName": "s3://${var.athena_storage_bucket_name}",
            "athenaRegion": "${data.aws_region.current.name}",
            "athenaDatabase": "kubecost_${data.aws_caller_identity.current.account_id}",
            "athenaTable": "kubecost_${data.aws_caller_identity.current.account_id}",
            "projectID": "${data.aws_caller_identity.current.account_id}"
        }
    ]
}
    EOF
  }
}

resource "kubernetes_secret" "kubecost_saml_secret" {
  count = var.primary_cluster && var.saml_enabled ? 1 : 0
  metadata {
    name      = "kubecost-saml"
    namespace = var.namespace
    labels    = var.kubecost_non_helm_k8s_labels
  }

  data = {
    "myservice.cert" = var.saml_secret
  }
}
