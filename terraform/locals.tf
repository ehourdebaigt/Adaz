locals {
  domain = yamldecode(file(var.domain_config_file))
}