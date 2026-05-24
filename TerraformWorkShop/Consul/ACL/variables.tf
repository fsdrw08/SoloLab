variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
  })
}

variable "prov_consul" {
  type = object({
    scheme          = string
    address         = string
    insecure_https  = bool
    datacenter      = string
    token_plaintext = optional(string, null)
    token_reference = optional(
      object({
        vault_kvv2 = optional(
          object({
            mount = string
            name  = string
            key   = string
        }), null)
    }), null)
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
