# All common k8s resources defined here

resource "kubernetes_secret" "federated_store" {
  metadata {
    name      = "federated-store"
    namespace = var.namespace
  }

  data = {
    "federated-store.yaml" = <<EOF
type: S3
config:
  bucket: ${var.federated_storage_bucket}
  endpoint: "s3.amazonaws.com"
  region: ${var.primary_s3_bukcet_region}
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
