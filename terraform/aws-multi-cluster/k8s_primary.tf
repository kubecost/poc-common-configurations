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

  depends_on = [kubernetes_secret.kubecost_license]

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
forecasting:
  enabled: false

kubecostAggregator:
  deployMethod: statefulset

kubecostModel:
  federatedStorageConfigSecret: federated-store
serviceAccount:
  annotations:
    "eks.amazonaws.com/role-arn": ${aws_iam_role.kubecost_federated_storage.arn}
    
    EOF
  ]
}

resource "kubernetes_secret" "kubecost_license" {
  count = var.primary_cluster ? 1 : 0
  metadata {
    name      = "kubecost-license"
    namespace = var.namespace
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
  }

  data = {
    "cloud-integration.json" = <<EOF
{
    "aws": [
        {
            "athenaBucketName": "s3://${var.athena_storage_bucket}",
            "athenaRegion": "us-west-2",
            "athenaDatabase": "kubecost_776719623202",
            "athenaTable": "kubecost_776719623202",
            "projectID": "776719623202"
        }
    ]
}
    EOF
  }
}

