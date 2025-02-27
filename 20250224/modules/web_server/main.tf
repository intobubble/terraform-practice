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
# EC2
#-------------------------------
resource "aws_instance" "main" {
  for_each               = var.instance
  instance_type          = each.value["instance_type"]
  subnet_id              = each.value["subnet_id"]
  vpc_security_group_ids = each.value["vpc_security_group_ids"]
  key_name               = each.value["key_name"]

  iam_instance_profile        = aws_iam_instance_profile.instance_profile_main.name
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true

  tags = {
    Name = local.tag_name
  }
}

#-------------------------------
# Instance Profile
#-------------------------------
resource "aws_iam_instance_profile" "instance_profile_main" {
  name = local.tag_name
  role = aws_iam_role.main.name
}

#-------------------------------
# IAM Policy
#-------------------------------
resource "aws_iam_policy" "main" {
  depends_on = [aws_instance.main]

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
          "${var.s3["bucket_arn"]}",
          "${var.s3["bucket_arn"]}/*"
        ]
      }
    ]
  })
}

#-------------------------------
# IAM Role
#-------------------------------
resource "aws_iam_role" "main" {
  name = "ec2-role"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

#-------------------------------
# Role Policy Attachment
#-------------------------------
resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}


