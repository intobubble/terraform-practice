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

module "network_public" {
  source = "./modules/network-public"

  environment    = var.environment
  system_name    = "web-sample"
  vpc_cidr_block = "172.16.0.0/16"

  subnet_map_list = [
    {
      "name"              = "public-1",
      "cidr_block"        = "172.16.0.0/16",
      "availability_zone" = "ap-northeast-1a"
    }
  ]
}

resource "aws_key_pair" "developer" {
  key_name   = "developer"
  public_key = var.public_key_developer
}

module "instance" {
  source = "./modules/ec2"

  environment = var.environment
  system_name = "web-sample"

  instance_map_list = [
    {
      "name"          = "public-1",
      "instance_type" = "t2.micro",
      "subnet_id"     = module.network_public.subnet_ids["public-1"]
      "key_name"      = aws_key_pair.developer.key_name
      "vpc_security_group_ids" = [
        module.network_public.vpc_sg_id_http_ipv4,
        module.network_public.vpc_sg_id_ssh_ipv4,
      ]
    }
  ]
}
