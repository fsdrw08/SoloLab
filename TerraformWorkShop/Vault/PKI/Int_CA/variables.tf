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
    cert = object({
      internal_sign = optional(object({
        backend     = string
        common_name = string
        ttl_years   = number
      }), null)
      external_import = optional(object({
        ref_cert_bundle_path = string
      }), null)
    })
    issuer = object({
      name                           = string
      revocation_signature_algorithm = string
    })
  })
}
