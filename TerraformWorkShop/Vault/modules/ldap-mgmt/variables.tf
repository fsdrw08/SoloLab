## vault_ldap_auth_backend
# # ldap auth path
# variable "ldap_path" {
#   description = "(Optional) Path to mount the LDAP auth backend under"
#   type        = string
#   default     = "ldap"
# }

# # ldap connection
# variable "ldap_url" {
#   description = "(Required) The URL of the LDAP server"
#   type        = string
#   default     = null
# }

# variable "ldap_starttls" {
#   description = "(bool, optional) - If true, issues a StartTLS command after establishing an unencrypted connection."
#   type        = bool
#   default     = false
# }

# variable "ldap_insecure_tls" {
#   description = "(bool, optional) - If true, skips LDAP server SSL certificate verification - insecure, use with caution!"
#   type        = bool
#   default     = false
# }

# variable "ldap_certificate" {
#   description = "(string, optional) - CA certificate to use when verifying LDAP server certificate, must be x509 PEM encoded."
#   type        = string
#   default     = null
# }

# # Binding - Authenticated Search
# variable "ldap_binddn" {
#   description = "(string, optional) - Distinguished name of object to bind when performing user and group search. Example: cn=vault,ou=Users,dc=example,dc=com"
#   type        = string
#   default     = null
# }

# variable "ldap_bindpass" {
#   description = "(string, optional) - Password to use along with binddn when performing user search."
#   type        = string
#   default     = null
#   sensitive   = true
# }

# # User resolution
# variable "ldap_userdn" {
#   description = "(string, optional) - Base DN under which to perform user search. Example: ou=Users,dc=example,dc=com"
#   type        = string
#   default     = null
# }

# variable "ldap_userattr" {
#   description = "(string, optional) - Attribute on user attribute object matching the username passed when authenticating. Examples: sAMAccountName, cn, uid"
#   type        = string
#   default     = null
# }

# # Group Membership Resolution
# variable "ldap_groupdn" {
#   description = "(string, required) - LDAP search base to use for group membership search. This can be the root containing either groups or users. Example: ou=Groups,dc=example,dc=com"
#   type        = string
#   default     = null
# }

# variable "ldap_groupattr" {
#   description = "(string, optional) - LDAP attribute to follow on objects returned by groupfilter in order to enumerate user group membership. Examples: for groupfilter queries returning group objects, use: cn. For queries returning user objects, use: memberOf. The default is cn."
#   type        = string
#   default     = "cn"
# }

# variable "ldap_groupfilter" {
#   description = "(string, optional) - Go template used when constructing the group membership query. The template can access the following context variables: [UserDN, Username]. The default is (|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}})), which is compatible with several common directory schemas. To support nested group resolution for Active Directory, instead use the following query: (&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))."
#   type        = string
#   default     = null
# }

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
    token_type              = optional(string, "")
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
      ldap_url = string
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

# variable "policy_name" {
#   description = "(string: <required>) – Specifies the name of the policy to retrieve. This is specified as part of the request URL."
#   type        = string
#   default     = null
# }

# variable "policy_content" {
#   description = "(string: <required>) - Specifies the policy document."
#   type        = string
#   default     = null
# }
