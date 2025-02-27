locals {
  tag_name = join("-", [var.system_name, var.environment])
}

#-------------------------------
# ALB
#-------------------------------
resource "aws_lb" "main" {
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [for sg in var.security_group : sg["id"]]
  subnets                    = [for s in var.subnet : s["id"]]
  enable_deletion_protection = false

  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# ALB Target Group
#-------------------------------
resource "aws_lb_target_group" "main" {
  target_type      = "instance"
  protocol_version = "HTTP1"
  port             = 8080
  protocol         = "HTTP"
  vpc_id           = var.vpc["id"]

  tags = {
    Name = local.tag_name
  }
}

resource "aws_lb_target_group_attachment" "main" {
  for_each         = var.instance
  target_id        = each.value["id"]
  target_group_arn = aws_lb_target_group.main.arn
}

#-------------------------------
# ALB Listener
#-------------------------------
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "8080"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = local.tag_name
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  action {
    type = "redirect"
    redirect {
      port        = "8080"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
