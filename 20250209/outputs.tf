output "subnet_arn" {
  description = "arn subnet"
  value       = aws_subnet.main.arn
}

output "vpc_arn" {
  description = "arn VPC"
  value       = aws_vpc.main.arn
}

output "internet_gateway_arn" {
  description = "arn internet gateway"
  value       = aws_internet_gateway.main.arn
}

output "instance_arn" {
  description = "arn EC2 instance"
  value       = aws_instance.web.arn
}

output "instance_public_ip_address" {
  description = "IP adderss EC2 instance"
  value       = aws_instance.web.public_ip
}
