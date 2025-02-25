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

module "vpc" {
  source                   = "./modules/vpc"
  system_name              = var.system_name
  environment              = var.environment
  vpc_cidr_block           = var.vpc["vpc_cidr_block"]
  subnet_availability_zone = var.vpc["subnet_availability_zone"]
  subnet_cidr_block        = var.vpc["subnet_cidr_block"]
}

module "webserver" {
  source                     = "./modules/webserver"
  system_name                = var.system_name
  environment                = var.environment
  key_pair_public_key        = var.webserver["key_pair_public_key"]
  s3_bucket_name             = var.webserver["s3_bucket_name"]
  ec2_subnet_id              = module.vpc.subnet_id
  ec2_vpc_security_group_ids = module.vpc.vpc_security_group_ids
}

module "alb" {
  system_name = var.system_name
  environment = var.environment
  source      = "./modules/alb"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = [module.vpc.subnet_id]
  instance_id = module.webserver.instance_id
}


