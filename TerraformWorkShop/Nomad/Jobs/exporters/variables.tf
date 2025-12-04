variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}

# variable "prov_vault" {
#   type = object({
#     address         = string
#     token           = string
#     skip_tls_verify = bool
#   })
# }

variable "jobs" {
  type = list(object({
    path = string
    var_sets = optional(
      list(object({
        name                = string
        value_string        = optional(string, null)
        value_template_path = optional(string, null)
        value_template_vars = optional(map(string), {})
      })),
      null
    )
  }))
}
