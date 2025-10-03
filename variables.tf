variable "aws_region" {
  description = "The AWS region to deploy the resources into."
  type        = string
}

variable "wordpress_ami_id" {
  description = "The ID of the custom WordPress AMI to use for the Launch Template."
  type        = string
}
variable "db_name" {
  description = "The Database name on database instance."
  type        = string
  sensitive   = true
}
variable "db_username" {
  description = "The master username for the RDS database instance."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The master password for the RDS database instance."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {}
variable "db_engine_version" {}
variable "db_sng_id" {type = string} 
variable "db_sng_name" {type = string} 
variable "db_address" {type = string} 


variable "bucket_name" {
  description = "The master password for the RDS database instance."
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "edward-wordpress"
} 


variable "asg_threshold" { type = number }
variable "asg_cooldown" { type = number }

variable "keypair_name" {type = string} 

variable "vpc_cidr" {type = string} 
variable "vpc_private_subnet" {type = string}
variable "vpc_public_subnet" {type = string} 
variable "vpc_subnet_count" {type = string} 
variable "new_bits" {
  description = "The number of additional bits for subnet allocation (e.g., 8 for /24 subnets from a /16 VPC)."
  type        = number
  default     = 8
}

variable "asg_sg" {type = string} 
