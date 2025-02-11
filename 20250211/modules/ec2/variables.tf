variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}


variable "instance_map_list" {
  type = list(
    object({
      name                   = string
      instance_type          = string
      subnet_id              = string
      key_name               = string
      vpc_security_group_ids = list(string)
    })
  )
}
