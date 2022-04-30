resource "aws_lb_listener_rule" "frontend" {
  listener_arn = var.listener_arn

  condition {
    path_pattern {
      values = ["${var.path_prefix}/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group" "main" {
  name_prefix = substr(var.name, 0, 6)
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path    = "${var.path_prefix}/health"
    matcher = 200
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

