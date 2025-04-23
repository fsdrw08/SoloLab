variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "prov_consul" {
  type = object({
    scheme         = string
    address        = string
    datacenter     = string
    token          = string
    insecure_https = bool
  })
}

variable "consul_roles" {
  type = list(object({
    name            = string
    consul_policies = list(string)
    ttl             = number
    groups_binding  = list(string)
  }))
}
