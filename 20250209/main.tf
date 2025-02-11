terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = var.tags
}


resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.0.0/16"
  depends_on        = [aws_vpc.main]
  tags              = var.tags

  lifecycle {
    replace_triggered_by = [aws_vpc.main]
  }
}

resource "aws_internet_gateway" "main" {
  depends_on = [aws_vpc.main]
  tags       = var.tags
}

resource "aws_internet_gateway_attachment" "vpc_gw_attachment" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

resource "aws_network_interface" "main" {
  subnet_id = aws_subnet.main.id
  tags      = var.tags
}

resource "aws_route_table" "main" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main, aws_subnet.main]
  tags       = var.tags
}

resource "aws_route" "route_gw" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64*"]
  }
  tags = var.tags
}

resource "aws_security_group" "sg_vpc" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.sg_vpc.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.sg_vpc.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_vpc.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = var.tags
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.sg_vpc.id
  ]
  key_name   = aws_key_pair.developer.key_name
  depends_on = [aws_internet_gateway.main]

  tags = var.tags
}

resource "aws_key_pair" "developer" {
  key_name   = "developer"
  public_key = var.public_key_developer
}
