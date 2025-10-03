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


data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name

  vpc_private_subnet = var.vpc_public_subnet
  vpc_public_subnet = var.vpc_public_subnet
  vpc_subnet_count = var.vpc_subnet_count

  vpc_cidr       = var.vpc_cidr
  #public_subnets = ["192.168.1.0/24", "192.168.2.0/24"]
  #private_subnets = ["192.168.101.0/24", "192.168.102.0/24"]
  aws_region     = var.aws_region
}

module "app" {
  source = "./modules/app"

  asg_sg = module.vpc.asg_sg
  db_address = module.db.db_address

  asg_cooldown = var.asg_cooldown
  asg_threshold = var.asg_threshold

  keypair_name = var.keypair_name

  project_name = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids

  wordpress_ami_id      = var.wordpress_ami_id
  db_name               = var.db_name 
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_engine_version     = var.db_engine_version

  instance_type         = var.instance_type
  desired_capacity      = 2
  max_capacity          = 4
  min_capacity          = 2
}


module "db" {
  source = "./modules/db"

  asg_cooldown = var.asg_cooldown
  asg_threshold = var.asg_threshold

  db_sng_id = module.vpc.db_sng_id
  db_sng_name = module.vpc.db_sng_name

  keypair_name = var.keypair_name

  project_name = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids

  wordpress_ami_id      = var.wordpress_ami_id
  db_name               = var.db_name 
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_engine_version     = var.db_engine_version

  instance_type         = var.instance_type
  desired_capacity      = 2
  max_capacity          = 4
  min_capacity          = 2
}