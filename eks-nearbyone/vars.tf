variable "config_defaults" {
  type = object({
    aws_region     = string,
    cluster_name   = string,
    initial_nodes  = number,
    max_nodes      = number,
    allowed_users  = map(string)
    instance_types = list(string)
  })
  default = {
    "aws_region"     = "eu-west-1"
    "cluster_name"   = ""
    "initial_nodes"  = 2
    "max_nodes"      = 3
    "allowed_users"  = {}
    "instance_types" = ["m4.2xlarge"]
  }
}

variable "local_config" {}

locals {
  config = merge(var.config_defaults, var.local_config)
}
