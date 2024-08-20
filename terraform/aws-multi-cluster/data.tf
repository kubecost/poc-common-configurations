data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "aws_eks_cluster" {
  name = var.cluster_id
}
