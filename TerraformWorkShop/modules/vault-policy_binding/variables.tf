
variable "policy_bindings" {
  type = list(object({
    policy_name    = string
    policy_content = string
    group_binding = optional(
      object({
        policy_group    = string
        external_groups = list(string)
      }),
      null
    )
    token_binding = optional(
      object({
        display_name     = optional(string, null)
        explicit_max_ttl = optional(string, null)
        no_parent        = optional(bool, null)
        period           = optional(string, null)
        renewable        = optional(string, null)
        ttl              = optional(string, null)
      }),
      null
    )
  }))
}
