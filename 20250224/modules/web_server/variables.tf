variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}


variable "key_pair" {
  type = object({
    public_key = string
  })
}

variable "s3" {
  type = object({
    bucket_name = string
  })
}

variable "instance" {
  type = object({
    instance_1 = object({
      instance_type          = string
      subnet_id              = string
      vpc_security_group_ids = list(string)
    })
    instance_2 = object({
      instance_type          = string
      subnet_id              = string
      vpc_security_group_ids = list(string)
    })
  })
}
