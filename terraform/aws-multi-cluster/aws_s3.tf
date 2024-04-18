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

# The kubecost_athena_bucket stores results of queries run against AWS Athena.
resource "aws_s3_bucket" "kubecost_athena_bucket" {
  count  = var.primary_cluster ? 1 : 0
  bucket = var.athena_storage_bucket
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "Kubecost_athena_private_access" {
  count               = var.primary_cluster ? 1 : 0
  bucket              = aws_s3_bucket.kubecost_athena_bucket[0].id
  block_public_acls   = true
  block_public_policy = true
}
