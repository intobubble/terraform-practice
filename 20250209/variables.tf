variable "public_key_developer" {
  description = "public key for EC2 instance"
  type        = string
}

variable "tags" {
  description = "tag name"

  type = object({
    Name = string
  })

  default = {
    Name = "developer"
  }
}

