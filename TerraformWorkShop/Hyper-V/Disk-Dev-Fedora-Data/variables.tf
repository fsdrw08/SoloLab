variable "provider_hyperv" {
  type = object({
    user     = string
    password = string
    host     = string
    port     = number
  })
  # default = {
  #   user     = "root"
  #   password = "P@ssw0rd"
  #   host     = "127.0.0.1"
  #   port     = 5986
  # }
}

variable "vhd" {
  type = object({
    path       = string
    type       = string
    size       = number
    block_size = number
  })
}

