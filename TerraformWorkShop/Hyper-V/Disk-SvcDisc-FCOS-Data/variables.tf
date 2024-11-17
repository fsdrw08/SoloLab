variable "hyperv" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
  default = {
    host     = "127.0.0.1"
    port     = 5986
    user     = "root"
    password = "P@ssw0rd"
  }
}

variable "vhd" {
  type = object({
    path       = string
    type       = string
    size       = number
    block_size = number
  })
}

