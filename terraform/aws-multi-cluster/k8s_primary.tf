# K8s resources for Kubecost Primary cluster defined here. The Helm provider
# effectively performs a `helm template` then `kubectl apply`.

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
  count = var.primary_cluster ? 1 : 0
  metadata {
    name      = "kubecost-license"
    namespace = var.namespace
  }

  data = {
    "productkey.json" = var.license
  }
}
