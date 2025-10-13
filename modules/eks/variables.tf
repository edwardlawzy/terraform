variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

# variable "wordpress_ami_id" {}
variable "ami_type" {}
variable "instance_type" {}
variable "desired_capacity" { type = number }
variable "max_capacity" { type = number }
variable "min_capacity" { type = number }


variable "project_name" {type = string} 


# variable "keypair_name" {type = string} 
