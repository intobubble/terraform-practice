output "subnet_ids" {
  value = { for i in var.subnet_map_list : i.name => aws_subnet.main[i.name].id }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_securty_gorup_id_http_ipv4" {
  value = aws_security_group.http_ipv4.id
}
