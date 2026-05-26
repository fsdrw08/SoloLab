variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
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
