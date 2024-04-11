data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster" "aws_eks_cluster" {
  name = var.cluster_id
}

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

resource "aws_s3_bucket_versioning" "kubecost_federated_storage" {
  count  = var.primary_cluster ? 1 : 0
  bucket = aws_s3_bucket.kubecost_federated_storage[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kubecost_federated_storage" {
  count  = var.primary_cluster ? 1 : 0
  bucket = aws_s3_bucket.kubecost_federated_storage[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      kms_master_key_id = ""
    }
  }
}

# This is to allow kubecost applications to read and write to federated S3 bucket
# This is to be done for primary and secondary
resource "aws_iam_role" "kubecost_federated_storage" {
  count = var.primary_cluster ? 1 : 0
  name  = "kubecost_federated_storage-s3"

  assume_role_policy = templatefile("${path.module}/irsa-trust.tmpl", {
    account_id      = data.aws_caller_identity.current.account_id,
    oidc            = replace(data.aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer, "https://", "")
    namespace       = var.namespace
    service-account = "kubecost-cost-analyzer"
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


resource "aws_iam_role" "kubecost_federated_storage_tobe_used_second" {
  count = var.primary_cluster ? 1 : 0
  name  = "kubecost_federated_storage-s3_secon"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.secondary_account_number}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "kubecost_federated_storage_tobe_used_second" {
  count      = var.primary_cluster ? 1 : 0
  role       = aws_iam_role.kubecost_federated_storage_tobe_used_second[count.index].name
  policy_arn = aws_iam_policy.kubecost_federated_storage[count.index].arn
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  count  = var.primary_cluster ? 1 : 0
  bucket = aws_s3_bucket.kubecost_federated_storage[0].id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.secondary_account_number}:role/kubecost_federated_storage-s3-atmos-mdev"
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
