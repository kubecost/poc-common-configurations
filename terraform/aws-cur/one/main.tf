data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket" "kubecost_s3_athena" {
  bucket        = "enterprise-kubecost-athena-query-results-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = var.tags

  lifecycle {
    ignore_changes = [
      bucket,
      tags,
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "kubecost_s3_athena" {
  bucket = aws_s3_bucket.kubecost_s3_athena.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "kubecost_s3_athena" {
  depends_on = [aws_s3_bucket_ownership_controls.kubecost_s3_athena]

  bucket = aws_s3_bucket.kubecost_s3_athena.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kubecost_s3_athena" {
  bucket = aws_s3_bucket.kubecost_s3_athena.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "kubecost_s3_athena" {
  bucket              = aws_s3_bucket.kubecost_s3_athena.id
  block_public_acls   = true
  block_public_policy = true
}

#TODO Change to role
resource "aws_iam_user" "kubecost_user" {
  name = var.kubecost_user
  tags = var.tags
}

resource "aws_iam_policy" "kubecost_user_policy" {
  name        = "${var.kubecost_user}-policy"
  description = "A policy required by kubecost"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "athena:*"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow",
            "Sid": "AthenaAccess"
        },
        {
            "Action": [
                "glue:GetDatabase*",
                "glue:GetTable*",
                "glue:GetPartition*",
                "glue:GetUserDefinedFunction",
                "glue:BatchGetPartition"
            ],
            "Resource": [
                "arn:aws:glue:*:*:catalog",
                "arn:aws:glue:*:*:database/athenacurcfn*",
                "arn:aws:glue:*:*:table/athenacurcfn*/*",
                "arn:aws:glue:*:*:database/enterprisekubecost*",
                "arn:aws:glue:*:*:table/enterprisekubecost*/*"
            ],
            "Effect": "Allow",
            "Sid": "ReadAccessToAthenaCurDataViaGlue"
        },
        {
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:AbortMultipartUpload",
                "s3:CreateBucket",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::kubecost-athena-query-results-*",
                "arn:aws:s3:::kubecost-cur*"
            ],
            "Effect": "Allow",
            "Sid": "AthenaQueryResultsOutput"
        },
        {
            "Action": [
                "ec2:Describe*"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow",
            "Sid": "EC2DescribeVolume"
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "kubecost_user_policy_attachment" {
  user       = aws_iam_user.kubecost_user.name
  policy_arn = aws_iam_policy.kubecost_user_policy.arn
}

data "template_file" "crawler_cfn" {
  template = file("${path.module}/crawler-cfn.yml")
  vars = {
    CUR_BUCKET : var.cur_bucket,
    CUR_PREFIX : var.cur_prefix,
    CUR_COST_AND_USAGE_DATA_STATUS_PATH : var.cur_cost_and_usage_data_status_path,
    ACCOUNT_NUM : data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudformation_stack" "kubecost" {
  name = "enterprisekubecost"

  template_body = data.template_file.crawler_cfn.rendered
  capabilities  = ["CAPABILITY_IAM"]

  tags = var.tags
}