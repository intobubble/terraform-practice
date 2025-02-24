variable "environment" {
  description = "env"
  type        = string
}

variable "system_name" {
  description = "system name"
  type        = string
}

variable "network_public" {
  type = object({
    vpc_cidr_block           = string
    subnet_availability_zone = string
    subnet_cidr_block        = string
  })
}

variable "webserver" {
  type = object({
    key_pair_public_key = string
    s3_bucket_name      = string
  })
}
