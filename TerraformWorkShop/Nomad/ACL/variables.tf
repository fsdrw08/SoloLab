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

variable "policy_bindings" {
  type = list(object({
    name        = string
    description = optional(string, null)
    rules       = string
    role = optional(object({
      name        = string
      description = optional(string, null)
      }),
      null
    )
    token = optional(object({
      type            = optional(string, "client")
      vault_kvv2_path = string
      }),
      {
        type            = "client"
        vault_kvv2_path = null
      }
    )
  }))
}
