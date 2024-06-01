variable "hyperv_host" {
  type    = string
  default = "127.0.0.1"
}

variable "hyperv_port" {
  type    = string
  default = 5986
}

variable "hyperv_user" {
  type = string
}

variable "hyperv_password" {
  type = string
}

variable "vhd" {
  type = object({
    path       = string
    type       = string
    size       = number
    block_size = number
  })
}

