variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "mount" {
  type = string
}

variable "databases" {
  type = list(object({
    name           = string
    user_name      = string
    secret_version = number
  }))
}
