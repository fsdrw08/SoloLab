variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "oidc_provider" {
  type = object({
    issuer = string
    scopes = optional(
      list(
        object({
          name     = string
          template = string
        })
      ), null
    )
  })
}
