variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "approles" {
  type = list(
    object({
      role_name             = string
      role_id               = optional(string, null)
      bind_secret_id        = optional(bool, true)
      secret_id_bound_cidrs = optional(list(string), null)
      secret_id_num_uses    = optional(number, null)
      secret_id_ttl         = optional(number, null)

      token_ttl               = optional(number, null)
      token_max_ttl           = optional(number, null)
      token_period            = optional(string, null)
      token_policies          = optional(list(string), null)
      token_bound_cidrs       = optional(list(string), null)
      token_explicit_max_ttl  = optional(number, null)
      token_no_default_policy = optional(bool, false)
      token_num_uses          = optional(number, null)
      token_type              = optional(string, null)
      alias_metadata          = optional(map(string), null)

      secret_version = optional(number, 1)
    })
  )
}

variable "vault_secret_backend" {
  type = string
}