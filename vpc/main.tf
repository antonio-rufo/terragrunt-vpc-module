terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = "> 0.12.4"
}

###############################################################################
# Providers
###############################################################################
provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/assumed-terraform"
    session_name = "TERRAFORM_SESSION"
    external_id  = "TECH_OPS_TF"
  }
}

locals {
  tags = {
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
}

###############################################################################
# Base Network
###############################################################################
module "base_network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name                 = var.vpc_name
  cidr                 = var.cidr_range
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.public_cidr_ranges
  public_subnets       = var.private_cidr_ranges
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}
