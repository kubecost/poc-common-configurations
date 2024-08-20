# Kubecost federated storage is the s3 bucket which all clusters push metrics to.
resource "aws_s3_bucket" "kubecost_federated_storage" {
  count  = var.primary_cluster ? 1 : 0
  bucket = var.federated_storage_bucket_name

  force_destroy = var.force_destroy_s3_buckets

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_private_access" {
  count                   = var.primary_cluster ? 1 : 0
  bucket                  = aws_s3_bucket.kubecost_federated_storage[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "kubecost_federated_storage_lifecycle" {
  count  = var.primary_cluster ? 1 : 0
  bucket = aws_s3_bucket.kubecost_federated_storage[0].id
  rule {
    id = "expire"
    expiration {
      days = var.federated_storage_days
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  count  = length(var.secondary_account_numbers) > 0 && var.primary_cluster ? 1 : 0
  bucket = aws_s3_bucket.kubecost_federated_storage[0].id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            for account_number in var.secondary_account_numbers : "arn:aws:iam::${account_number}:root"
          ]
        },
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.federated_storage_bucket_name}/*",
          "arn:aws:s3:::${var.federated_storage_bucket_name}"
        ]
      }
    ]
  })
}

# The kubecost_athena_bucket stores results of queries run against AWS Athena.
resource "aws_s3_bucket" "kubecost_athena_bucket" {
  count  = var.primary_cluster ? 1 : 0
  bucket = var.athena_storage_bucket_name

  force_destroy = var.force_destroy_s3_buckets

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "kubecost_athena_private_access" {
  count                   = var.primary_cluster ? 1 : 0
  bucket                  = aws_s3_bucket.kubecost_athena_bucket[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "kubecost_athena_storage_lifecycle" {
  count  = var.primary_cluster ? 1 : 0
  bucket = aws_s3_bucket.kubecost_athena_bucket[0].id
  rule {
    id = "expire"
    expiration {
      days = var.athena_storage_days
    }
    status = "Enabled"
  }
}
