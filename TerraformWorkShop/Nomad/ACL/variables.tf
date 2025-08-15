variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}

# variable "NOMAD_TOKEN" {
#   type = string
# }

variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "policies" {
  type = list(object({
    name        = string
    description = optional(string, null)
    rules       = string
  }))
}

variable "roles" {
  type = list(object({
    name                  = string
    description           = optional(string, null)
    policy_names          = list(string)
    auth_binding_selector = optional(string, null)
    token = optional(object({
      type = optional(string, "client")
      store = optional(object({
        vault_kvv2_path = optional(string, null)
      }), null)
    }), null)
  }))
}
