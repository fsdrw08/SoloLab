variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "vault_kvv2" {
  type = object({
    secret_engine = object({
      path        = string
      description = optional(string, null)
    })
    config = optional(object({
      max_versions = optional(number, null)
    }), null)
    data_key_name = object({
      ca          = string
      cert        = string
      private_key = string
    })
  })

}

variable "vault_certs" {
  type = list(object({
    secret_engine = object({
      backend   = string
      role_name = string
    })
    common_name = string
    ttl_years   = number
    revoke      = optional(bool, null)
  }))
}
