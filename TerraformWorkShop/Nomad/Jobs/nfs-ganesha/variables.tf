variable "prov_system" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}
