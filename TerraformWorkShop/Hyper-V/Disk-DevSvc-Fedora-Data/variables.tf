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

variable "vhd" {
  type = object({
    path       = string
    type       = string
    size       = number
    block_size = number
  })
}

