variable "prov_ldap" {
  type = object({
    host          = string
    port          = number
    tls           = bool
    tls_insecure  = bool
    bind_user     = string
    bind_password = string
  })
}
variable "base_dn" {
  type = string
}

variable "ldap_groups" {
  type = list(object({
    dn   = string
    data = map(list(string))
  }))
}

variable "ldap_accounts" {
  type = list(object({
    dn   = string
    data = map(list(string))
  }))
}
