#------------------------------------------------------------------------------
# Provider
#------------------------------------------------------------------------------
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  security_group_ingress = {
    default = {
      description = "Nessus Inbound"
      from_port   = 8834
      protocol    = "tcp"
      to_port     = 8834
      self        = false
      cidr_blocks = ["0.0.0.0/0"]
    },
    ssh = {
      description = "ssh"
      from_port   = 22
      protocol    = "tcp"
      to_port     = 22
      self        = false
      cidr_blocks = ["10.0.0.0/16"]
    }
  }
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = "terratest-vpc"
  cidr               = "10.0.0.0/16"
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = var.tags
}

module "nessus-appliance" {
  source                 = "../../"
  security_group_ingress = local.security_group_ingress
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.vpc.public_subnets[0]
  nessus_key             = "dloiijfhqoiewrubfoqieuurbfcpoiqweunrcopiqeuhnrfpoiu13ehrwft"
  external_id            = "dfasdfasdfihqewprijfnqwepikjnf"
  cloud_connector        = true
}
