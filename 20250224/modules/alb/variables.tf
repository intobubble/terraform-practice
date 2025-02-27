variable "system_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb" {
  type = object({
    vpc = object({
      id = string
    })
    subnet = map(object({
      id = string
    }))
    security_group = map(object({
      id = string
    }))
    instance = map(object({
      id = string
    }))
  })
}
