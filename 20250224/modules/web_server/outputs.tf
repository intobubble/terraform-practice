output "instance" {
  value = [for value in aws_instance.main : value]
}
