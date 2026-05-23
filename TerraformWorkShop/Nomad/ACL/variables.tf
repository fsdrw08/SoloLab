variable "prov_nomad" {
  type = object({
    address          = string
    skip_verify      = bool
    secret_plaintext = optional(string, null)
    secret_reference = optional(
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

# variable "NOMAD_TOKEN" {
#   type = string
# }

variable "prov_vault" {
  type = object({
    address         = string
    token           = optional(string, null)
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
    policy_names          = optional(list(string), null)
    auth_binding_selector = optional(string, null)
    token = optional(object({
      type = optional(string, "client")
      store = optional(object({
        vault_kvv2_path = optional(string, null)
      }), null)
    }), null)
  }))
}
