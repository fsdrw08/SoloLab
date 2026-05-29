variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
  })
}

variable "secrets" {
  type = list(object({
    mount              = string
    name               = string
    generate_passwords = optional(list(string), [])
    content            = map(string)
    secret_version     = number
  }))
}
