variable "vault_ldap_auth" {
  description = "Provides a resource for managing an LDAP auth backend within Vault."
  type = map(object({
    # https://developer.hashicorp.com/vault/docs/auth/ldap
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
  }))
}

## vault_identity_group vault_identity_group_alias
variable "vault_groups" {
  description = "Creates an Identity Group for Vault. The Identity secrets engine is the identity management solution for Vault."
  # https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes
  type = map(object({
    type     = optional(string)
    policies = optional(list(string))
    metadata = optional(map(any))
    # alias    = list(string)
    alias = optional(list(object({
      name     = string
      ldap_key = string
    })))
  }))
}

## vault_policy
variable "vault_policies" {
  description = "value"
  type = map(object({
    policy_content = string
  }))
}

