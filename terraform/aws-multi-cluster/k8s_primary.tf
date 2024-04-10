resource "helm_release" "kubecost_core_primary" {
  count = var.primary_cluster ? 1 : 0

  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = var.kubecost_version
  namespace  = var.namespace


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
    "eks.amazonaws.com/role-arn": ${aws_iam_role.kubecost_federated_storage[0].arn}
    
    EOF
  ]
}

resource "kubernetes_secret" "kubecost_license" {
  metadata {
    name = "kubecost-license"
    namespace = var.namespace
  }

  data = {
    "productkey.json" = base64encode(var.license)
  }
}

resource "kubernetes_secret" "federated_store" {
  metadata {
    name = "federated-store"
    namespace = var.namespace
  }

  data = {
    "federated-store.yaml" = <<EOF
type: S3
config:
  bucket: ${var.federated_storage_bucket}
  endpoint: "s3.amazonaws.com"
  region: ${data.aws_region.current.name}
  insecure: false
  signature_version2: false
  put_user_metadata:
      "X-Amz-Acl": "bucket-owner-full-control"
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 2m
    insecure_skip_verify: false
  trace:
    enable: true
  part_size: 134217728
EOF
  }

  depends_on = [
    aws_s3_bucket.kubecost_federated_storage
  ]
}

