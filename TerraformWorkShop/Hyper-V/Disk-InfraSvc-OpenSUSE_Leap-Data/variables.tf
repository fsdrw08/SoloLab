variable "user" {
  type    = string
  default = null
}

variable "password" {
  type      = string
  default   = null
  sensitive = true
}

variable "host" {
  type    = string
  default = null
}
