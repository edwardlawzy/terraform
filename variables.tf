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

variable "bucket_name" {
  description = "The master password for the RDS database instance."
  type        = string
  sensitive   = true
}
