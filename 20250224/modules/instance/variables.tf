variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance" {
  type = map(
    object({
      instance_type          = string
      subnet_id              = string
      vpc_security_group_ids = list(string)
      key_name               = string
    })
  )
}

variable "s3" {
  type = object({
    bucket_arn = string
  })
}
