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
    Name = join("-", [var.system_name, var.environment])
  }
}

#-------------------------------
# Subnet
#-------------------------------
resource "aws_subnet" "this" {
  for_each          = var.subnet
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value["availability_zone"]
  cidr_block        = each.value["cidr_block"]

  depends_on = [aws_vpc.main]
  tags = {
    Name = join("-", [var.system_name, var.environment])
  }
}


#-------------------------------
# Security Gorup
#-------------------------------
resource "aws_security_group" "http_ipv4" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]
  tags = {
    Name = join("-", [var.system_name, var.environment, "http_ipv4"])
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_ipv4_ingress" {
  security_group_id = aws_security_group.http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "http_ipv4_egress" {
  security_group_id = aws_security_group.http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "https_ipv4" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]
  tags = {
    Name = join("-", [var.system_name, var.environment, "https_ipv4"])
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_ipv4_ingress" {
  security_group_id = aws_security_group.https_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "https_ipv4_egress" {
  security_group_id = aws_security_group.https_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "ssh_ipv4" {
  vpc_id = aws_vpc.main.id

  depends_on = [aws_vpc.main]
  tags = {
    Name = join("-", [var.system_name, var.environment, "ssh_ipv4"])
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ipv4_ingress" {
  security_group_id = aws_security_group.ssh_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "ssh_ipv4_egress" {
  security_group_id = aws_security_group.ssh_ipv4.id
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
    Name = join("-", [var.system_name, var.environment])
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
    Name = join("-", [var.system_name, var.environment])
  }
}

resource "aws_internet_gateway_attachment" "attach_to_main_vpc" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}
