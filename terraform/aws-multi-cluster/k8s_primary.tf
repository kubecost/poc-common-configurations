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
forecasting:
  enabled: false

kubecostAggregator:
  deployMethod: statefulset

kubecostModel:
  federatedStorageConfigSecret: federated-store
serviceAccount:
  annotations:
    "eks.amazonaws.com/role-arn": ${aws_iam_role.kubecost_federated_storage.arn}

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
