variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "policy_bindings" {
  type = list(object({
    policy_name    = string
    policy_content = string
    # policy_group    = string
    # external_groups = list(string)
    group_binding = optional(
      object({
        policy_group    = string
        external_groups = list(string)
      }),
      null
    )
  }))
}
