variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}


variable "vpc" {
  type = object({
    id = string
  })
}

variable "subnet" {
  type = map(object({
    id = string
  }))
}

variable "security_group" {
  type = map(object({
    id = string
  }))
}

variable "instance" {
  type = map(object({
    id = string
  }))
}
