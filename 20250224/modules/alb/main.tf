locals {
  tag_name = join("-", [var.system_name, var.environment])
}

#-------------------------------
# ALB
#-------------------------------
resource "aws_lb" "this" {
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.this.id]
  subnets                    = var.subnet_ids
  enable_deletion_protection = false

  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# Security Group
#-------------------------------
resource "aws_security_group" "this" {
  vpc_id = var.vpc_id

  tags = {
    Name = local.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "this_ingress" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "this_egress" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#-------------------------------
# ALB Target Group
#-------------------------------
resource "aws_lb_target_group" "this" {
  target_type      = "instance"
  protocol_version = "HTTP1"
  port             = 8080
  protocol         = "HTTP"
  vpc_id           = var.vpc_id

  tags = {
    Name = local.tag_name
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count            = length(var.instance_ids)
  target_id        = var.instance_ids[count.index]
  target_group_arn = aws_lb_target_group.this.arn
}

#-------------------------------
# ALB Listener
#-------------------------------
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
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

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.this.arn
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
