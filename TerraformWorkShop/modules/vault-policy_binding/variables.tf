
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
        token_name = string
        token_ttl  = optional(string, null)

      }),
      null
    )
  }))
}
