terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr       = "192.168.0.0/16"
  public_subnets = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnets = ["192.168.101.0/24", "192.168.102.0/24"]
  aws_region     = var.aws_region
}

module "app" {
  source = "./modules/app"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids

  wordpress_ami_id      = var.wordpress_ami_id
  
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = "db.t3.micro"
  db_engine_version     = "8.0"

  instance_type         = "t3.small"
  desired_capacity      = 2
  max_capacity          = 4
  min_capacity          = 2
}
