variable "vault_ldap_auth_backend" {
  description = "Provides a resource for managing an LDAP auth backend within Vault."
  # https://developer.hashicorp.com/vault/docs/auth/ldap
  type = object({
    url                  = string
    starttls             = optional(string, null)
    case_sensitive_names = optional(bool, false)
    tls_min_version      = optional(string, null)
    tls_max_version      = optional(string, null)
    insecure_tls         = optional(bool, null)
    certificate          = optional(string, null)
    binddn               = optional(string, null)
    bindpass             = optional(string, null)
    userdn               = optional(string, null)
    userattr             = optional(string, null)
    userfilter           = optional(string, null)
    upndomain            = optional(string, null)
    discoverdn           = optional(bool, null)
    deny_null_bind       = optional(bool, null)
    groupfilter          = optional(string, null)
    groupdn              = optional(string, null)
    groupattr            = optional(string, null)
    username_as_alias    = optional(bool, null)
    use_token_groups     = optional(bool, null)
    path                 = optional(string, null)
    disable_remount      = optional(bool, null)
    description          = optional(string, null)
    local                = optional(bool, null)

    # Common Token Arguments
    token_ttl               = optional(number, null)
    token_max_ttl           = optional(number, null)
    token_period            = optional(number, null)
    token_policies          = optional(list(string), null)
    token_bound_cidrs       = optional(list(string), null)
    token_explicit_max_ttl  = optional(number, null)
    token_no_default_policy = optional(bool, null)
    token_num_uses          = optional(number, null)
    token_type              = optional(string, null)
  })
  # }))
}

variable "ldap_vault_entities" {
  type = object({
    users = optional(object({
      ou     = string
      filter = string
    }))
    groups = optional(object({
      ou     = string
      filter = string
    }))
  })
}
