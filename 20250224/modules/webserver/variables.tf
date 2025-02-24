variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "key_pair_public_key" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "ec2_subnet_id" {
  type = number
}

variable "ec2_vpc_security_group_ids" {
  type = list(number)
}
