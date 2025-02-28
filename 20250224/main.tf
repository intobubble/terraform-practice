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
  alias  = "ap-northeast-1"
}

locals {
  tag_name = join("-", [var.system_name, var.environment])
}

#-------------------------------
# VPC
#-------------------------------
module "vpc" {
  source      = "./modules/vpc"
  system_name = var.system_name
  environment = var.environment

  vpc = {
    cidr_block = "192.168.0.0/20"
  }
  subnet = {
    subnet_1 = {
      availability_zone = "ap-northeast-1a",
      cidr_block        = "192.168.1.0/24"
    },
    subnet_2 = {
      availability_zone = "ap-northeast-1c",
      cidr_block        = "192.168.2.0/24"
    },
  }
}

#-------------------------------
# S3
#-------------------------------
resource "aws_s3_bucket" "main" {
  bucket = "intobubble-webserver"

  tags = {
    Name = local.tag_name
  }
}


#-------------------------------
# AWS Key Pair
#-------------------------------
resource "aws_key_pair" "main" {
  for_each   = var.key_pair
  key_name   = each.value["key_name"]
  public_key = each.value["public_key"]

  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# EC2 Instance
#-------------------------------
module "instance" {
  source     = "./modules/instance"
  depends_on = [module.vpc, aws_key_pair.main, aws_s3_bucket.main]

  system_name = var.system_name
  environment = var.environment

  instance = {
    instance_1 = {
      instance_type = "t2.micro"
      subnet_id     = module.vpc.subnet["subnet_1"]["id"]
      key_name      = aws_key_pair.main["developer"].key_name
      vpc_security_group_ids = [
        module.vpc.secrity_group["allow_http"]["id"],
        module.vpc.secrity_group["allow_https"]["id"],
        module.vpc.secrity_group["allow_ssh"]["id"],
      ]
    }
    instance_2 = {
      instance_type = "t2.micro"
      subnet_id     = module.vpc.subnet["subnet_2"]["id"]
      key_name      = aws_key_pair.main["developer"].key_name
      vpc_security_group_ids = [
        module.vpc.secrity_group["allow_http"]["id"],
        module.vpc.secrity_group["allow_https"]["id"],
        module.vpc.secrity_group["allow_ssh"]["id"],
      ]
    }
  }
  s3 = {
    bucket_arn = aws_s3_bucket.main.arn
  }
}

#-------------------------------
# ALB
#-------------------------------
module "alb" {
  source     = "./modules/alb"
  depends_on = [module.instance, module.vpc]

  system_name = var.system_name
  environment = var.environment

  vpc = {
    id = module.vpc.vpc["id"]
  }
  subnet = {
    for k, v in module.vpc.subnet : k => { id : v["id"] }
  }
  instance = {
    for k, v in module.instance.instance : k => { id : v["id"] }
  }
}


