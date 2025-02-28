locals {
  tag_name = join("-", [var.system_name, var.environment])
}

#-------------------------------
# VPC
#-------------------------------
resource "aws_vpc" "main" {
  cidr_block                           = var.vpc["cidr_block"]
  enable_dns_hostnames                 = false
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"
  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# Subnet
#-------------------------------
resource "aws_subnet" "main" {
  for_each          = var.subnet
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value["availability_zone"]
  cidr_block        = each.value["cidr_block"]

  depends_on = [aws_vpc.main]
  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# Security Group
# Allow HTTP
#-------------------------------
resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]
  tags = {
    Name = local.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ingress" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_http_egress" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#-------------------------------
# Security Group
# Allow HTTPS
#-------------------------------
resource "aws_security_group" "allow_https" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]
  tags = {
    Name = local.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ingress" {
  security_group_id = aws_security_group.allow_https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_https_egress" {
  security_group_id = aws_security_group.allow_https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#-------------------------------
# Security Group
# Allow SSH
#-------------------------------
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]
  tags = {
    Name = local.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_egress" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#-------------------------------
# Route Table
#-------------------------------
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]
  tags = {
    Name = local.tag_name
  }
}

resource "aws_main_route_table_association" "main" {
  route_table_id = aws_route_table.main.id
  vpc_id         = aws_vpc.main.id
}

resource "aws_route" "route_gw" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

#-------------------------------
# Internet Gateway
#-------------------------------
resource "aws_internet_gateway" "main" {
  depends_on = [aws_vpc.main]
  tags = {
    Name = local.tag_name
  }
}

resource "aws_internet_gateway_attachment" "attach_to_main_vpc" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}
