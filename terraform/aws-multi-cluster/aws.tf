# AWS resources associated with the Kubecost primary. It is recommended to create these resources before creating the secondary cluster resources.

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "aws_eks_cluster" {
  name = var.cluster_id
}

# Kubecost federated storage is the s3 bucket which all clusters push metrics to.
resource "aws_s3_bucket" "kubecost_federated_storage" {
  count  = var.primary_cluster ? 1 : 0
  bucket = var.federated_storage_bucket
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_private_access" {
  count               = var.primary_cluster ? 1 : 0
  bucket              = aws_s3_bucket.kubecost_federated_storage[0].id
  block_public_acls   = true
  block_public_policy = true
}

# This allows the k8s serviceaccount to assume the IAM role. The role gets attached to a policy which allows read/write access to the Kubecost federated storage bucket.
resource "aws_iam_role" "kubecost_federated_storage" {
  count = var.primary_cluster ? 1 : 0
  name  = "kubecost_federated_storage-s3"

  assume_role_policy = templatefile("${path.module}/irsa-trust.tmpl", {
    account_id      = data.aws_caller_identity.current.account_id,
    oidc            = replace(data.aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer, "https://", "")
    namespace       = var.namespace
    service-account = "${var.kubecost_helm_release_name}-cost-analyzer"
  })

  tags = var.tags
}

resource "aws_iam_policy" "kubecost_federated_storage" {
  count = var.primary_cluster ? 1 : 0
  name  = "kubecost_federated_storage-s3-policy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.federated_storage_bucket}/*",
                "arn:aws:s3:::${var.federated_storage_bucket}"
            ]
        }
    ]
}
POLICY
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "kubecost_federated_storage" {
  count      = var.primary_cluster ? 1 : 0
  role       = aws_iam_role.kubecost_federated_storage[count.index].name
  policy_arn = aws_iam_policy.kubecost_federated_storage[count.index].arn
}

# A bucket policy is required to allow Kubecost deployments in other AWS accounts to push to the Kubecost federated storage bucket.
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  count  = var.primary_cluster ? 1 : 0
  bucket = aws_s3_bucket.kubecost_federated_storage[0].id
  # TODO: Currently only allows specifying a single secondary account number. Need to be able to add _multiple_ secondary accounts
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.secondary_account_number}:root"
            },
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.federated_storage_bucket}/*",
                "arn:aws:s3:::${var.federated_storage_bucket}"
            ]
        }
    ]
}
POLICY
}
