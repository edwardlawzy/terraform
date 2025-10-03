resource "aws_alb" "alb" {
    name               = "${var.project_name}-alb"
    internal           = false
    load_balancer_type = "application"
    subnets            = var.public_subnet_ids
    security_groups    = [var.asg_sg]
}

resource "aws_alb_target_group" "alb-tg" {
      name     = "${var.project_name}-alb-tg"
      port     = 80
      protocol = "HTTP"
      vpc_id   = var.vpc_id

      health_check {
        path = "/"
        port = "80"
        # protocol            = "HTTP"
        # matcher             = "200"
        # interval            = 30
        # timeout             = 5
        # healthy_threshold   = 2
        # unhealthy_threshold = 2
      }

}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = aws_alb.alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_alb_target_group.alb-tg.arn
    }
}

# resource "aws_alb_listener_rule" "alb-listener-rule" {
#     listener_arn = aws_alb_listener.alb-listener.arn
#     priority     = 100

#     action {
#       type             = "forward"
#       target_group_arn = aws_alb_target_group.alb-tg.arn
#     }

#     condition {
#       path_pattern {
#         values = ["/api/*"]
#       }
#     }
# }