variable "environment" {
  description = "env"
  type        = string
}

variable "system_name" {
  description = "system name"
  type        = string
}

variable "key_pair" {
  description = "public key"
  type = map(
    object({
      key_name   = string
      public_key = string
    })
  )
}
