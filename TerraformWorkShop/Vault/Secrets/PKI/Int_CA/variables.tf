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
      backend = string
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
    enable_backend_config = bool
    csr = optional(object({
      common_name = string
      ttl_years   = number
    }), null)
    issuer = optional(object({
      name                           = string
      revocation_signature_algorithm = string
    }), null)
    roles = optional(list(object({
      name             = string
      ext_key_usage    = optional(list(string), null)
      ttl_months       = number
      key_type         = string
      key_bits         = number
      allow_ip_sans    = bool
      allowed_domains  = list(string)
      allow_subdomains = bool
      allow_any_name   = bool
    })), null)
    acme_allowed_roles = optional(list(string), null)
    public_fqdn        = optional(string, null)
  }))
}
