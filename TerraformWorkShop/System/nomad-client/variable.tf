variable "prov_system" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
    sudo     = bool
  })
}

variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}
