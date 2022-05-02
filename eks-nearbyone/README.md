# What's this?

Terraform module to provision an EKS cluster for NearbyOne.

# Example usage

```
terraform {
  backend "s3" {
    bucket         = "nbycomp-terraform"
    key            = "demonstrators1.tfstate"    # CHANGE THIS FOR EACH CLUSTER
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }

  required_version = ">= 0.14"
}

# you should provide this when calling the module
variable "config" {}

module "eks_nearbyone" {
  source = "git@github.com:nbycomp/nearbyone-terraform-modules.git//eks-nearbyone"
  local_config = var.config
}
```
