provider "aws" {
  region = local.config["aws_region"]
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", local.config["cluster_name"], "--region", local.config["aws_region"]]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", local.config["cluster_name"], "--region", local.config["aws_region"]]
    command     = "aws"
  }
}

module "acm_certs" {
  source    = "./certs"
  tls_names = local.config["tls_names"]
}

module "eks_cluster" {
  source        = "./cluster"
  cluster_name  = local.config["cluster_name"]
  initial_nodes = local.config["initial_nodes"]
  max_nodes     = local.config["max_nodes"]
}


module "load_balancer_controller" {
  source  = "DNXLabs/eks-lb-controller/aws"
  version = "0.5.1"

  cluster_identity_oidc_issuer     = module.eks_cluster.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks_cluster.oidc_provider_arn
  cluster_name                     = local.config["cluster_name"]
}

module "cluster_autoscaler" {
  source  = "DNXLabs/eks-cluster-autoscaler/aws"
  version = "0.1.2"

  enabled = true

  cluster_name                     = local.config["cluster_name"]
  cluster_identity_oidc_issuer     = module.eks_cluster.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks_cluster.oidc_provider_arn
  aws_region                       = local.config["aws_region"]
}

module "eks-auth" {
  source  = "aidanmelen/eks-auth/aws"
  version = "0.8.2"
  eks     = module.eks_cluster

  patch = true

  map_users = [for username, arn in local.config["allowed_users"] :
    {
      userarn  = arn
      username = username
      groups   = ["system:bootstrappers", "system:nodes", "system:masters"]
    }
  ]
}

output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks_cluster.cluster_id
}
