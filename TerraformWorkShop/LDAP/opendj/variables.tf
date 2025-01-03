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
