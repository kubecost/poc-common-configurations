terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.15.0, < 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0, < 3.0.0"
    }
  }
  required_version = ">= 1.0.0, < 2.0.0"
}
