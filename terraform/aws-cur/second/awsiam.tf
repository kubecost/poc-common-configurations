resource "aws_cloudformation_stack" "kubecostiam" {
  name = "kubecostiam"
  template_body = templatefile("${path.module}/iam-cfn.yml",
    { CUR_BUCKET : var.cur_bucket,
      CUR_PREFIX : var.cur_prefix,
      ACCOUNT_NUM : data.aws_caller_identity.current.account_id,
      AWS_KUBECOST_ROLE : var.aws_kubecost_role
  })
  capabilities = ["CAPABILITY_NAMED_IAM"]
  parameters = {
    SpotDataFeedBucketName : ""
  }

  tags = merge(
    var.default_tags
  )
}

resource "local_file" "kubecost_assume_role_policy_document" {
  filename = local.kubecost_role_trust_policy_filename
  content = templatefile(local.role_trust_policy_filename, {
    ACCOUNT_ID        = data.aws_caller_identity.current.account_id,
    AWS_KUBECOST_ROLE = var.aws_kubecost_role
  })

  depends_on = [
    aws_cloudformation_stack.kubecostiam
  ]
}

resource "null_resource" "update_kubecost_role_trust_policy" {
  provisioner "local-exec" {
    command = "sleep 10;aws iam update-assume-role-policy --role-name ${var.aws_kubecost_role} --policy-document file://${local_file.kubecost_assume_role_policy_document.filename}"
  }

  triggers = {
    sha = local_file.kubecost_assume_role_policy_document.content_sha1
  }

  depends_on = [local_file.kubecost_assume_role_policy_document]
}