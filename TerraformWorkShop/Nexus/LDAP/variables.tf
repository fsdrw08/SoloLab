variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
  })
}

variable "prov_sonatyperepo" {
  type = object({
    url = string
    credential = optional(
      map(object({
        plaintext = optional(string, null)
        vault_kvv2 = optional(
          object({
            mount = string
            name  = string
            key   = string
          }),
          null
        )
      })),
      null
    )
  })
}

variable "ldap" {
  type = object({
    auth_scheme               = string # "NONE" "CRAM_MD5" "DIGEST_MD5" "SIMPLE"
    hostname                  = string
    name                      = string
    port                      = number
    protocol                  = string
    search_base               = string
    user_email_name_attribute = string
    user_id_attribute         = string
    user_object_class         = string
    user_real_name_attribute  = string

    auth_password             = optional(string, null)
    auth_realm                = optional(string, null)
    auth_username             = optional(string, null)
    connection_retry_delay    = optional(number, 5)
    connection_timeout        = optional(number, 10)
    group_base_dn             = optional(string, null)
    group_id_attribute        = optional(string, null)
    group_member_attribute    = optional(string, null)
    group_member_format       = optional(string, null)
    group_object_class        = optional(string, null)
    group_subtree             = optional(bool, null)
    group_type                = optional(string, null) # "STATIC" "DYNAMIC"
    map_ldap_groups_to_roles  = optional(bool, null)
    max_connection_attempts   = optional(number, 3)
    nexus_trust_store_enabled = optional(bool, null)
    order                     = optional(number, null)
    user_base_dn              = optional(string, null)
    user_ldap_filter          = optional(string, null)
    user_member_of_attribute  = optional(string, null)
    user_password_attribute   = optional(string, null)
    user_subtree              = optional(bool, null)
  })
}

variable "roles" {
  type = list(object({
    name       = string
    id         = string
    privileges = list(string)
  }))
}

variable "local_users" {
  type = list(object({
    email_address = string
    first_name    = string
    last_name     = string
    roles         = list(string)
    status        = string
    user_id       = string

    password = optional(string, null)
  }))
}