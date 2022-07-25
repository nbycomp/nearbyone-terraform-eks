# EKS cluster provisioning with Terraform

Please, when deploying a NearbyONE controller using these instructions, set the namespace to the name of the project.

# Prerequisites

- aws cli executable in your `PATH`
- valid aws cli config either under `~/.aws` or exported `AWS_*` environment variables

# Manage EKS cluster

To configure and update the cluster you should:

- (Only if you've been given a tgz) Decompress the terraform module tgz, let's assume for this example that the module ends up in `/some/path/eks-nearbyone`
- Set appropriate values for the cluster in `vars.auto.tfvars` (see sample below)
- Create main module `main.tf` (see below)
- `terraform init`
- `terraform plan`
- `terraform apply`
- `terraform apply -refresh-only` (first time only)


## Example vars.auto.tfvars

For explanation purposes, the below sample includes comments, which are not allowed in the actual file you'll create.

```
config = {
  aws_region     = "eu-west-2"      # replace with your actual region
  cluster_name   = "clustername"    # set to a name of your liking, will be shown in the EKS dashboard
  initial_nodes  = 2
  instance_types = ["m4.2xlarge"]
  allowed_users  = {
    # AWS usernames and ARNs of users which will be allowed to use the cluster
    "user1" = "arn:aws:iam::111111111111:user/user1",
    "user2" = "arn:aws:iam::111111111111:user/user2",
  }
}
```

## Example main.tf

```
terraform {
  # configure this as appropriate for your env,
  # here's an example with state stored in s3
  backend "s3" {
    bucket         = "bucketname"
    key            = "clustername.tfstate"
    region         = "eu-west-1"       ### CHANGE THIS
    encrypt        = true
    dynamodb_table = "terraform"       ### CHANGE THIS
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.75.1"
    }
  }

  required_version = ">= 0.14"
}

variable "config" {}

module "eks_nearbyone" {
  # use this if you decompressed the tgz
  source = "/some/path/eks-nearbyone"
  # use this for direct github install
  # source = "git@github.com:nbycomp/nearbyone-terraform-eks.git//eks-nearbyone"

  local_config = var.config
}
```

## What does `refresh-only` do?

It might happen that in a resource managed with terraform, attributes appear which are not declared in the terraform code (this is exactly what happens with this eks module); in this case, terraform detects the change but since they are "external" it just informs the user without taking any actions. Running `terraform apply -refresh-only` refresh terraform's state with those attributes; this is only for convenience, as the same thing would happen anyway on the next run of `terraform apply`.
[This very well-written article](https://nedinthecloud.com/2021/12/23/terraform-apply-when-external-change-happens/) explains the concepts, recommended reading. The scenario that applies here is the one described in the `Changes made to Non-managed Attributes` paragraph, but the full text is worth reading.

# Get `kubeconfig`

Run the following command:

```
aws eks update-kubeconfig --name <clustername> --region <aws_region> --kubeconfig /path/to/kubeconfig
```

You can now install NearbyOne.

# Delete EKS cluster

- Delete all NearbyOne environments running on the custer
- `terraform destroy`
