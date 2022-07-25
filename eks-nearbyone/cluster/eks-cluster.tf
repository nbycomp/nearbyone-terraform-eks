variable "cluster_name" {}
variable "initial_nodes" {}
variable "max_nodes" {}
variable "instance_types" {}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.6"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # enable OIDC
  enable_irsa = true

  eks_managed_node_group_defaults = {
    root_volume_type = "gp2"
    instance_types   = var.instance_types
    tags = { "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned",
    "k8s.io/cluster-autoscaler/enabled" = "true" }
  }

  eks_managed_node_groups = {
    ng1 = {
      min_size               = 1
      max_size               = var.max_nodes
      desired_size           = var.initial_nodes
      create_launch_template = false
      launch_template_name   = ""
      name                   = substr("NG1-${var.cluster_name}", 0, 30)
    },
  }
}
