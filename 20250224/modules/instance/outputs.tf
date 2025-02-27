output "instance" {
  value = { for k, v in aws_instance.main : k => v }
}
