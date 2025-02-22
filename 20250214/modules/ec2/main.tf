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


resource "aws_instance" "main" {
  for_each = { for i in var.instance_map_list : i.name => i }

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  key_name                    = each.value.key_name
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  iam_instance_profile        = each.value.iam_instance_profile
  associate_public_ip_address = true

  tags = {
    Name = join("-", [var.system_name, var.environment, each.value.name])
  }
}
