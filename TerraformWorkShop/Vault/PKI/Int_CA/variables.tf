variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "vault_pki" {
  type = object({
    mount = object({
      path                    = string
      description             = string
      default_lease_ttl_years = number
      max_lease_ttl_years     = number
    })
    role = object({
      name             = string
      ttl_years        = number
      key_type         = string
      key_bits         = number
      allow_ip_sans    = bool
      allowed_domains  = list(string)
      allow_subdomains = bool
      allow_any_name   = bool
    })
    issuer = object({
      name                           = string
      revocation_signature_algorithm = string
    })
  })
}
