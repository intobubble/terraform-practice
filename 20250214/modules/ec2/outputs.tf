output "instance_public_ip" {
  value = { for i in var.instance_map_list : i.name => aws_instance.main[i.name].public_ip }
}
