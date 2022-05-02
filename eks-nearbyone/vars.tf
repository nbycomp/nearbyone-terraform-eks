variable "config_defaults" {
  type = object({
    aws_region = string,
    cluster_name = string,
    tls_names = list(string),
    initial_nodes = number,
    max_nodes = number,
    allowed_users = map(string)
  })
  default = {
    "aws_region" = "eu-west-1"
    "cluster_name" = ""
    "tls_names" = []
    "initial_nodes" = 2
    "max_nodes" = 3
    "allowed_users" = {}
  }
}

variable local_config {}

locals {
  config = merge(var.config_defaults, var.local_config)
}
