resource "aws_security_group" "asg_sg" {
  name        = "wordpress-asg-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/4"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "wordpress-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.asg_sg.id] # Only allow access from ASG
  }
}

resource "aws_db_subnet_group" "rds_sng" {
  name       = "edward-wordpress-rds-sng"
  subnet_ids = var.private_subnet_ids
  #subnet_ids = aws_subnet.public[0].id
  tags       = { Name = "RDS Subnet Group" }
}

resource "aws_db_instance" "wordpress_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  identifier             = "wordpress-db-instance"
  #private_ip             = "192.168.101.101"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_sng.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

resource "aws_launch_template" "wordpress_lt" {
  name_prefix   = "wordpress-lt-"
  image_id      = var.wordpress_ami_id
  instance_type = var.instance_type
  key_name      = "edward" 

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_sg.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
# sed -i 's/database_name_here/${aws_db_instance.wordpress_db.identifier}/g' /var/www/html/wp-config.php
# sed -i 's/username_here/${var.db_username}/g' /var/www/html/wp-config.php
# sed -i 's/password_here/${var.db_password}/g' /var/www/html/wp-config.php
 sed -i 's/192.168.101.101/${aws_db_instance.wordpress_db.address}/g' /var/www/html/wp-config.php
EOF
)
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                      = "wordpress-asg"
  vpc_zone_identifier       = var.public_subnet_ids
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity
  health_check_type         = "EC2"
  force_delete              = true

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "cpu-scale-out"
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "wordpress-asg-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50 # CPU reaches 50%
  alarm_description   = "Scale out when ASG CPU average is > 50%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.cpu_scale_out.arn]
}
