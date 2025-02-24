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

module "network_public" {
  source                   = "./modules/network_public"
  system_name              = var.system_name
  environment              = var.environment
  vpc_cidr_block           = var.network_public["vpc_cidr_block"]
  subnet_availability_zone = var.network_public["subnet_availability_zone"]
  subnet_cidr_block        = var.network_public["subnet_cidr_block"]
}

module "webserver" {
  source                     = "./modules/webserver"
  system_name                = var.system_name
  environment                = var.environment
  key_pair_public_key        = var.webserver["key_pair_public_key"]
  s3_bucket_name             = var.webserver["s3_bucket_name"]
  ec2_subnet_id              = module.network_public.subnet_id
  ec2_vpc_security_group_ids = module.network_public.vpc_security_group_ids
}



