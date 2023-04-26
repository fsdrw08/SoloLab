## vault_ldap_auth_backend
# ldap auth path
variable "ldap_path" {
  description = "(Optional) Path to mount the LDAP auth backend under"
  type        = string
  default     = "ldap"
}

# ldap connection
variable "ldap_url" {
  description = "(Required) The URL of the LDAP server"
  type        = string
  default     = null
}

variable "ldap_starttls" {
  description = "(bool, optional) - If true, issues a StartTLS command after establishing an unencrypted connection."
  type        = bool
  default     = false
}

variable "ldap_insecure_tls" {
  description = "(bool, optional) - If true, skips LDAP server SSL certificate verification - insecure, use with caution!"
  type        = bool
  default     = false
}

variable "ldap_certificate" {
  description = "(string, optional) - CA certificate to use when verifying LDAP server certificate, must be x509 PEM encoded."
  type        = string
  default     = null
}

# Binding - Authenticated Search
variable "ldap_binddn" {
  description = "(string, optional) - Distinguished name of object to bind when performing user and group search. Example: cn=vault,ou=Users,dc=example,dc=com"
  type        = string
  default     = null
}

variable "ldap_bindpass" {
  description = "(string, optional) - Password to use along with binddn when performing user search."
  type        = string
  default     = null
  sensitive   = true
}

# User resolution
variable "ldap_userdn" {
  description = "(string, optional) - Base DN under which to perform user search. Example: ou=Users,dc=example,dc=com"
  type        = string
  default     = null
}

variable "ldap_userattr" {
  description = "(string, optional) - Attribute on user attribute object matching the username passed when authenticating. Examples: sAMAccountName, cn, uid"
  type        = string
  default     = null
}

# Group Membership Resolution
variable "ldap_groupdn" {
  description = "(string, required) - LDAP search base to use for group membership search. This can be the root containing either groups or users. Example: ou=Groups,dc=example,dc=com"
  type        = string
  default     = null
}

variable "ldap_groupattr" {
  description = "(string, optional) - LDAP attribute to follow on objects returned by groupfilter in order to enumerate user group membership. Examples: for groupfilter queries returning group objects, use: cn. For queries returning user objects, use: memberOf. The default is cn."
  type        = string
  default     = "cn"
}

variable "ldap_groupfilter" {
  description = "(string, optional) - Go template used when constructing the group membership query. The template can access the following context variables: [UserDN, Username]. The default is (|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}})), which is compatible with several common directory schemas. To support nested group resolution for Active Directory, instead use the following query: (&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))."
  type        = string
  default     = null
}

## vault_identity_group vault_identity_group_alias
variable "groups" {
  description = "Creates an Identity Group for Vault. The Identity secrets engine is the identity management solution for Vault."
  type = map(object({
    group_type : string
    group_policies : list(string)
    group_alias : list(string)
  }))
}

# variable "group_name" {
#   description = "(Required, Forces new resource) Name of the identity group to create."
#   type        = string
#   default     = null
# }

# variable "group_type" {
#   description = "(Optional, Forces new resource) Type of the group, internal or external. Defaults to internal."
#   type        = string
#   default     = "internal"
# }

# variable "group_policies" {
#   description = "(Optional) A list of policies to apply to the group."
#   type        = list(string)
#   default     = null
# }

# ## vault_identity_group_alias
# variable "group_alias" {
#   description = "Group aliases allows entity membership in external groups to be managed semi-automatically."
#   type = map(object({
#     name : string
#     mount_accessor : string
#   }))
# }

## vault_policy
variable "vault_policies" {
  description = "value"
  type = map(object({
    policy_content : string
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
