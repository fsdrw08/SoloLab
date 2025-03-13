variable "prov_hyperv" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "vhd" {
  type = object({
    path       = string
    type       = string
    size       = number
    block_size = number
  })
}

