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
  type = map(
    object({
      availability_zone = string
      cidr_block        = string
    })
  )
}
