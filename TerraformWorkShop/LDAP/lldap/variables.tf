variable "prov_lldap" {
  type = object({
    http_url                 = string
    ldap_url                 = string
    insecure_skip_cert_check = bool
    username                 = string
    password                 = string
    base_dn                  = string
  })
}

variable "users" {
  type = list(object({
    user_id      = string
    email        = string
    password     = optional(string, null)
    display_name = string
  }))
}


variable "groups" {
  type = list(object({
    iac_id       = string
    display_name = string
    members      = list(string)
  }))
}
