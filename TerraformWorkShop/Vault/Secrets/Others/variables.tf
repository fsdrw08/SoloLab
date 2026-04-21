variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
  })
}

variable "secrets" {
  type = list(object({
    mount          = string
    name           = string
    content        = map(string)
    secret_version = number
  }))
}
