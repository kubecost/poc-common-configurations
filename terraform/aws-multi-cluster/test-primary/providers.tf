provider "aws" {
  region = var.region
}

data "external" "env" { program = ["jq", "-n", "env"] }

data "aws_eks_cluster" "aws_eks_cluster" {
  name = var.cluster_id
}

locals {
  eks_host               = data.aws_eks_cluster.aws_eks_cluster.endpoint
  cluster_ca_certificate = data.aws_eks_cluster.aws_eks_cluster.certificate_authority[0].data
  cluster_name           = data.aws_eks_cluster.aws_eks_cluster.name
}

provider "helm" {
  burst_limit = 1000
  kubernetes {
    host                   = local.eks_host
    cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
      env = {
        AWS_ACCESS_KEY_ID     = lookup(data.external.env.result, "AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY = lookup(data.external.env.result, "AWS_SECRET_ACCESS_KEY")
        AWS_SESSION_TOKEN     = lookup(data.external.env.result, "AWS_SESSION_TOKEN")
        AWS_DEFAULT_REGION    = lookup(data.external.env.result, "AWS_DEFAULT_REGION")
      }
    }
  }
}

provider "kubernetes" {
  host                   = local.eks_host
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    env = {
      AWS_ACCESS_KEY_ID     = lookup(data.external.env.result, "AWS_ACCESS_KEY_ID")
      AWS_SECRET_ACCESS_KEY = lookup(data.external.env.result, "AWS_SECRET_ACCESS_KEY")
      AWS_SESSION_TOKEN     = lookup(data.external.env.result, "AWS_SESSION_TOKEN")
      AWS_DEFAULT_REGION    = lookup(data.external.env.result, "AWS_DEFAULT_REGION")
    }
  }
}