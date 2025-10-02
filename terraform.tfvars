#---------------------------#
#--------- General ---------#
#---------------------------#

aws_region          = "us-east-1"

#-----------------------#
#--------- App ---------#
#-----------------------#

wordpress_ami_id    = "ami-0b25cf403d403b489"

#----------------------#
#--------- DB ---------#
#----------------------#

db_username         = "admin"
db_password         = "password"
db_name		    = "mydb"
db_instance_class   = "db.t3.micro"
db_engine_version   = "8.0"

#----------------------#
#--------- S3 ---------#
#----------------------#

bucket_name	   = "edward-terraform-s3"
