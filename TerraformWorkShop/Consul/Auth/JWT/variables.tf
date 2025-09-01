variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "prov_consul" {
  type = object({
    scheme         = string
    address        = string
    datacenter     = string
    token          = string
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
  }))
}

variable "acl_binding_rules" {
  type = list(object({
    iac_key     = string
    auth_name   = string
    bind_type   = string
    bind_name   = string
    description = optional(string, null)
    selector    = string
  }))
}
