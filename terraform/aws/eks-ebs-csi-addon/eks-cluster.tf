module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = var.node_group_one_name

      instance_types = [var.instance_type_one]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
#
#    two = {
#      name = var.node_group_two_name
#
#      instance_types = [var.instance_type_two]
#
#      min_size     = 1
#      max_size     = 3
#      desired_size = 1
#    }
  }
}
