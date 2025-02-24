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
  public_key = var.key_pair_public_key
}


#-------------------------------
# EC2
#-------------------------------
resource "aws_instance" "main" {
  instance_type               = "t3-micro"
  associate_public_ip_address = true
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.developer.key_name
  subnet_id                   = var.ec2_subnet_id
  vpc_security_group_ids      = var.ec2_vpc_security_group_ids
  iam_instance_profile        = aws_iam_instance_profile.instance_profile_main.name


  tags = {
    Name = join("-", [var.system_name, var.environment])
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
  bucket = var.s3_bucket_name

  tags = {
    Name = join("-", [var.system_name, var.environment])
  }
}


