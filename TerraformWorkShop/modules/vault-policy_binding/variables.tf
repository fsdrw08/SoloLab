
variable "policy_bindings" {
  type = list(object({
    policy_name     = string
    policy_content  = string
    policy_group    = string
    external_groups = list(string)
  }))
}
