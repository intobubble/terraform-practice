variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc" {
  type = object({
    cidr_block = string
  })
}

variable "subnet" {
  type = object({
    subnet_1 = object({
      availability_zone = string
      cidr_block        = string
    })
    subnet_2 = object({
      availability_zone = string
      cidr_block        = string
    })
  })
}
