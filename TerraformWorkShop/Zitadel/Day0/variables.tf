variable "prov_zitadel" {
  type = object({
    domain           = string
    insecure         = bool
    port             = number
    jwt_profile_file = string
  })
}

variable "prov_etcd" {
  type = object({
    endpoints = string
    ca_cert   = optional(string, null)
    username  = string
    password  = string
    skip_tls  = bool
  })
}

variable "ldap" {
  type = object({
    name                = string
    servers             = list(string)
    start_tls           = bool
    timeout             = string
    base_dn             = string
    bind_dn             = string
    bind_password       = string
    is_auto_creation    = bool
    is_auto_update      = bool
    is_creation_allowed = bool
    is_linking_allowed  = bool
    user_base           = string
    user_object_classes = list(string)
    user_filters        = list(string)
  })
}
