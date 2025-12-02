variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "oidc_provider" {
  type = object({
    name        = string
    issuer_host = string
    scopes = optional(
      list(
        object({
          name     = string
          template = string
        })
      ), []
    )
  })
}

variable "oidc_client" {
  type = list(
    object({
      name             = string
      allow_groups     = list(string)
      redirect_uris    = list(string)
      id_token_ttl     = optional(number, 2400)
      access_token_ttl = optional(number, 7200)
    })
  )
}

variable "vault_secret_backend" {
  type = string
}
