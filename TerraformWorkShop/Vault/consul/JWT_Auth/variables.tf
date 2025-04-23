variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "oidc_key" {
  type = object({
    name             = string
    algorithm        = string
    verification_ttl = number
    rotation_period  = number
  })
}

variable "oidc_roles" {
  type = list(object({
    name      = string
    ttl       = number
    client_id = string
    template  = string
  }))
}

variable "policy_bindings" {
  type = list(object({
    policy_name     = string
    policy_content  = string
    policy_group    = string
    external_groups = list(string)
  }))
}
