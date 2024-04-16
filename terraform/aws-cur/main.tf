provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {
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
  name = "kubecost"

  template_body = data.template_file.crawler_cfn.rendered
  capabilities  = ["CAPABILITY_IAM"]

  tags = var.tags
}
