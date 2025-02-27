output "vpc" {
  value = aws_vpc.main
}

output "subnet" {
  value = { for k, v in aws_subnet.main : k => v }
}

output "secrity_group" {
  value = {
    allow_http : aws_security_group.allow_http
    allow_https : aws_security_group.allow_https
    allow_ssh : aws_security_group.allow_ssh
    allow_redirect : aws_security_group.allow_redirect
  }
}
