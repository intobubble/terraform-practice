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
  system_name    = var.system_name
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
  depends_on = [module.network_public, aws_s3_bucket.main, aws_iam_role.ec2_role]
  source     = "./modules/ec2"

  environment = var.environment
  system_name = var.system_name

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
      "iam_instance_profile" = aws_iam_instance_profile.ec2_profile.name
    }
  ]
}

resource "aws_s3_bucket" "main" {
  bucket = "intobubble-webserver"

  tags = {
    Name = join("-", [var.system_name, var.environment, "intobubble-webserver"])
  }
}


# https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements.html
resource "aws_iam_policy" "ec2_policy" {
  depends_on = [aws_s3_bucket.main]

  name        = "ec2-policy"
  path        = "/"
  description = "This provides permission to EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:ListAllMyBuckets"
        ],
        Resource = [
          "${aws_s3_bucket.main.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.system_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
