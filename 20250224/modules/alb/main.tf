locals {
  tag_name = join("-", [var.system_name, var.environment])
}

#-------------------------------
# ALB
#-------------------------------
resource "aws_lb" "main" {
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_http.id]
  subnets                    = [for s in var.subnet : s["id"]]
  enable_deletion_protection = false

  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# ALB Listener
#-------------------------------
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }

  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# ALB Listener Rule
#-------------------------------
resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

#-------------------------------
# ALB Target Group
#-------------------------------
resource "aws_lb_target_group" "main" {
  target_type      = "instance"
  port             = 80
  protocol_version = "HTTP1"
  protocol         = "HTTP"
  vpc_id           = var.vpc["id"]

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

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
# Security Group
# from TCP
#-------------------------------
resource "aws_security_group" "allow_http" {
  tags = {
    Name = local.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}
