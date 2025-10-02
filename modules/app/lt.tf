resource "aws_launch_template" "wordpress_lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = var.wordpress_ami_id
  instance_type = var.instance_type
  key_name      = var.keypair_name

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