variable "prov_nexus" {
  type = object({
    insecure = bool
    url      = string
    username = string
    password = string
  })
}

# variable "prov_vault" {
#   type = object({
#     address         = string
#     token           = string
#     skip_tls_verify = bool
#   })
# }

variable "ldap" {
  type = object({
    auth_password                  = optional(string, null)
    auth_realm                     = optional(string, null)
    auth_schema                    = string # "NONE" "CRAM_MD5" "DIGEST_MD5" "SIMPLE"
    auth_username                  = optional(string, null)
    connection_retry_delay_seconds = optional(number, 5)
    connection_timeout_seconds     = optional(number, 10)
    group_base_dn                  = optional(string, null)
    group_id_attribute             = optional(string, null)
    group_member_attribute         = optional(string, null)
    group_member_format            = optional(string, null)
    group_object_class             = optional(string, null)
    group_subtree                  = optional(bool, null)
    group_type                     = optional(string, null)
    host                           = string
    ldap_groups_as_roles           = optional(bool, null)
    max_incident_count             = number
    name                           = string
    port                           = number
    protocol                       = string
    search_base                    = string
    use_trust_store                = optional(bool, null)
    user_base_dn                   = optional(string, null)
    user_email_address_attribute   = optional(string, null)
    user_id_attribute              = optional(string, null)
    user_ldap_filter               = optional(string, null)
    user_member_of_attribute       = optional(string, null)
    user_object_class              = optional(string, null)
    user_password_attribute        = optional(string, null)
    user_real_name_attribute       = optional(string, null)
    user_subtree                   = optional(bool, null)
  })
}

variable "roles" {
  type = list(object({
    name       = string
    roleid     = string
    privileges = list(string)
  }))
}
