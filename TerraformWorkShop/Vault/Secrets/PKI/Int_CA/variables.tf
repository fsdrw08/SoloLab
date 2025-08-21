variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "root_ca_ref" {
  type = object({
    internal = optional(object({
      backend     = string
      common_name = string
      ttl_years   = number
    }), null)
    external = optional(object({
      ref_cert_bundle_path = string
    }), null)
  })
}

variable "intermediate_cas" {
  type = list(object({
    secret_engine = object({
      path                    = string
      description             = string
      default_lease_ttl_years = optional(number, 0)
      max_lease_ttl_years     = optional(number, 0)
    })
    csr = object({
      common_name = string
      ttl_years   = number
    })
    public_fqdn = optional(string, null)
    issuer = object({
      name                           = string
      revocation_signature_algorithm = string
    })
    roles = list(object({
      name             = string
      ext_key_usage    = list(string)
      ttl_years        = number
      key_type         = string
      key_bits         = number
      allow_ip_sans    = bool
      allowed_domains  = list(string)
      allow_subdomains = bool
      allow_any_name   = bool
    }))
  }))
}

variable "vault_pki_secret_backend" {
  type = object({
    secret_engine = object({
      path                    = string
      description             = string
      default_lease_ttl_years = optional(number, 0)
      max_lease_ttl_years     = optional(number, 0)
    })
    public_fqdn = string
    role = object({
      name             = string
      ext_key_usage    = list(string)
      ttl_years        = number
      key_type         = string
      key_bits         = number
      allow_ip_sans    = bool
      allowed_domains  = list(string)
      allow_subdomains = bool
      allow_any_name   = bool
    })
    ca = object({
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
