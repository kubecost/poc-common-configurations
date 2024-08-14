locals {
    crawler_cfn = templatefile("${path.module}/crawler-cfn.yml", {
        CUR_BUCKET : var.cur_bucket_name,
        CUR_PREFIX : var.cur_prefix,
        CUR_COST_AND_USAGE_DATA_STATUS_PATH : var.cur_cost_and_usage_data_status_path,
        ACCOUNT_NUM : data.aws_caller_identity.current.account_id
    })
}

resource "aws_cloudformation_stack" "kubecost" {
  count = var.primary_cluster ? 1 : 0

  name          = var.kubecost_cloud_formation_stack_name
  template_body = local.crawler_cfn
  capabilities  = ["CAPABILITY_IAM"]

  tags = var.tags
}
