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

variable "policies" {
  type = list(object({
    name        = string
    datacenters = optional(list(string), null)
    description = optional(string, null)
    rules       = string
  }))
}

variable "roles" {
  type = list(object({
    name         = string
    description  = optional(string, null)
    policy_names = list(string)
    token_store = optional(object({
      vault_kvv2_path = optional(string, null)
    }), null)
  }))
}
