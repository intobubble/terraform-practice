variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_map_list" {
  type = list(
    object({
      name              = string
      cidr_block        = string
      availability_zone = string
    })
  )
}
