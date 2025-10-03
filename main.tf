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
  
  project_name = var.project_name

  vpc_private_subnet = "192.168.101.0/24"
  vpc_public_subnet = "192.168.1.0/24"
  vpc_subnet_count = "2"

  vpc_cidr       = var.vpc_cidr
  #public_subnets = ["192.168.1.0/24", "192.168.2.0/24"]
  #private_subnets = ["192.168.101.0/24", "192.168.102.0/24"]
  aws_region     = var.aws_region
}

module "app" {
  source = "./modules/app"

  asg_sg = var.asg_sg
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
  db_instance_class     = "db.t3.micro"
  db_engine_version     = "8.0"

  instance_type         = "t3.small"
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

  instance_type         = "t3.small"
  desired_capacity      = 2
  max_capacity          = 4
  min_capacity          = 2
}