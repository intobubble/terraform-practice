output "subnet_id" {
  value = aws_subnet.main.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_security_group_ids" {
  value = [
    aws_security_group.http_ipv4.id,
    aws_security_group.https_ipv4.id,
    aws_security_group.ssh_ipv4.id
  ]
}
