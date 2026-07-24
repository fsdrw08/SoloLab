variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
  })
}

variable "prov_consul" {
  type = object({
    scheme          = string
    address         = string
    datacenter      = string
    token_plaintext = optional(string, null)
    token_reference = optional(
      object({
        vault_kvv2 = object({
          mount = string
          name  = string
          key   = string
        })
    }), null)
    insecure_https = bool
  })
}

variable "jwt_auth_configs" {
  type = list(object({
    name = string
    config = object({
      JWKSURL           = string
      JWTSupportedAlgs  = optional(string, "RS256")
      BoundAudiences    = list(string)
      BoundIssuer       = optional(string, null)
      ClaimMappings     = map(string)
      ListClaimMappings = optional(map(string), null)
    })
    binding_rules = list(object({
      iac_id      = string
      bind_name   = string
      bind_type   = string
      description = optional(string, null)
      selector    = string
    }))
    roles = list(object({
      name         = string
      description  = optional(string, null)
      policy_names = list(string)
    }))
    policies = optional(list(object({
      name        = string
      datacenters = optional(list(string), null)
      description = optional(string, null)
      rules       = string
    })), [])
  }))
}
