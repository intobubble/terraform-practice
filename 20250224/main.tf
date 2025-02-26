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
  source      = "./modules/vpc"
  system_name = var.system_name
  environment = var.environment

  vpc = {
    cidr_block = "172.16.0.0/16"
  }

  subnet = {
    subnet_1 = {
      availability_zone = "ap-northeast-1a",
      cidr_block        = "172.16.0.0/16"
    },
    subnet_2 = {
      availability_zone = "ap-northeast-1a",
      cidr_block        = "172.16.0.0/16"
    },
  }
}

module "web_server" {
  source      = "./modules/web_server"
  depends_on  = [module.vpc]
  system_name = var.system_name
  environment = var.environment

  key_pair = {
    public_key = var.key_pair["public_key"]
  }

  s3 = {
    bucket_name = "intobubble_webserver"
  }

  instance = {
    instance_1 = {
      instance_type          = "t2-micro"
      subnet_id              = ""
      vpc_security_group_ids = [""]
    }
    instance_2 = {
      instance_type          = "t2-micro"
      subnet_id              = ""
      vpc_security_group_ids = [""]
    }
  }
}

module "alb" {
  source     = "./modules/alb"
  depends_on = [module.vpc]

  system_name  = var.system_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.subnet_ids
  instance_ids = [for i in module.web_server.instance : i["id"]]
}


