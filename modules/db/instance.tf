resource "aws_db_instance" "wordpress_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  identifier             = "${var.project_name}-db-instance"
  #private_ip             = "192.168.101.101"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_sng.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}