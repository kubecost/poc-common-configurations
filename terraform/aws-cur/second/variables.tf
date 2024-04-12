variable "default_tags" {
  description = "Default tags to always apply"
  type        = map(string)
}

variable "cur_bucket" {
  description = "AWS bucket containing CUR report"
}

variable "cur_prefix" {
  description = "AWS report prefix"
}

variable "aws_kubecost_role" {
  description = "Rolename used by aws kubecost"
}