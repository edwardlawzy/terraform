variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "wordpress_ami_id" {}
variable "instance_type" {}
variable "desired_capacity" { type = number }
variable "max_capacity" { type = number }
variable "min_capacity" { type = number }

variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance_class" {}
variable "db_engine_version" {}
