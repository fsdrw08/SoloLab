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

variable "policy_bindings" {
  type = list(object({
    name        = string
    description = optional(string, null)
    rules       = string
    datacenters = optional(list(string), null)
    role = optional(object({
      name        = string
      description = optional(string, null)
      }),
      null
    )
    token = optional(object({
      vault_kvv2_path = string
      }),
      null
    )
  }))
}
