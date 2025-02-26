locals {
  tag_name = join("-", [var.system_name, var.environment])
}

#-------------------------------
# AMI
#-------------------------------
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
}

#-------------------------------
# EC2 key pairs
#-------------------------------
resource "aws_key_pair" "developer" {
  key_name   = "developer"
  public_key = var.key_pair["public_key"]
}


#-------------------------------
# EC2
#-------------------------------
resource "aws_instance" "main" {
  for_each                    = var.instance
  instance_type               = each.value["instance_type"]
  subnet_id                   = each.value["subnet_id"]
  vpc_security_group_ids      = each.value["vpc_security_group_ids"]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile_main.name
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.developer.key_name
  associate_public_ip_address = true

  tags = {
    Name = local.tag_name
  }
}

resource "aws_iam_instance_profile" "instance_profile_main" {
  name = "${var.system_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}


#-------------------------------
# S3
#-------------------------------
resource "aws_s3_bucket" "main" {
  bucket = var.s3["bucket_name"]

  tags = {
    Name = local.tag_name
  }
}


