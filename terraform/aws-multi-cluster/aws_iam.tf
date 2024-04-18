# This allows the k8s serviceaccount to assume the IAM role. The role gets attached to a policy which allows read/write access to the Kubecost federated storage bucket.
resource "aws_iam_role" "kubecost_federated_storage" {
  name = "kubecost_federated_storage-s3-${var.cluster_id}"

  assume_role_policy = templatefile("${path.module}/irsa-trust.tmpl", {
    account_id      = data.aws_caller_identity.current.account_id,
    oidc            = replace(data.aws_eks_cluster.aws_eks_cluster.identity[0].oidc[0].issuer, "https://", "")
    namespace       = var.namespace
    service-account = "${var.kubecost_helm_release_name}-cost-analyzer"
  })

  tags = var.tags
}

resource "aws_iam_policy" "kubecost_federated_storage" {
  name = "kubecost_federated_storage-s3-policy-${var.cluster_id}"

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
  role       = aws_iam_role.kubecost_federated_storage.name
  policy_arn = aws_iam_policy.kubecost_federated_storage.arn
}

resource "aws_iam_policy" "kubecost_athena_cur" {
  count = var.primary_cluster ? 1 : 0
  name  = "kubecost_athena_cur_policy_${var.cluster_id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AthenaAccess",
      "Effect": "Allow",
      "Action": [
        "athena:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "ReadAccessToAthenaCurDataViaGlue",
      "Effect": "Allow",
      "Action": [
        "glue:GetDatabase*",
        "glue:GetTable*",
        "glue:GetPartition*",
        "glue:GetUserDefinedFunction",
        "glue:BatchGetPartition"
      ],
      "Resource": [
        "arn:aws:glue:*:*:catalog",
        "arn:aws:glue:*:*:database/kubecost*",
        "arn:aws:glue:*:*:table/kubecost*/*"
      ]
    },
    {
      "Sid": "AthenaQueryResultsOutput",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload",
        "s3:CreateBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.kubecost_athena_bucket[0].arn}",
        "${aws_s3_bucket.kubecost_athena_bucket[0].arn}/*"
      ]
    },
    {
      "Sid": "S3ReadAccessToAwsBillingData",
      "Effect": "Allow",
      "Action": [
          "s3:Get*",
          "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${var.cur_bucket_name}*"
      ]
    }
  ]
}
POLICY
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "kubecost_athena_cur" {
  count      = var.primary_cluster ? 1 : 0
  role       = aws_iam_role.kubecost_federated_storage.name
  policy_arn = aws_iam_policy.kubecost_athena_cur[0].arn
}