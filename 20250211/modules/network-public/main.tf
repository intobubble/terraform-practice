resource "aws_subnet" "main" {
  for_each = { for i in var.subnet_map_list : i.name => i }

  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  vpc_id = aws_vpc.main.id

  tags = {
    Name = join("-", [var.system_name, var.environment, each.value.name])
  }
}

resource "aws_vpc" "main" {
  cidr_block                           = var.vpc_cidr_block
  enable_dns_hostnames                 = false
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"
  tags = {
    Name = join("-", [var.system_name, var.environment])
  }
}

resource "aws_security_group" "http_ipv4" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = join("-", [var.system_name, var.environment])
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.http_ipv4.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

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

resource "aws_internet_gateway" "main" {
  tags = {
    Name = join("-", [var.system_name, var.environment])
  }
}

resource "aws_internet_gateway_attachment" "attach_to_main_vpc" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}
