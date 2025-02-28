
output "instance_public_ip" {
  value = { for k, v in module.instance.instance : k => v.public_ip }
}

output "alb_dns_name" {
  value = module.alb.alb.dns_name
}
