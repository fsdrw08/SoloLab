variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}

variable "dynamic_host_volumes" {
  type = list(object({
    name = string
    constraint = optional(
      list(object({
        attribute = string
        operator  = string
        value     = string
      })),
      null
    )
    capability = object({
      access_mode = optional(string, "single-node-writer")
    })
    plugin_id  = optional(string, "mkdir")
    parameters = optional(map(string), null)
  }))
  default = []
}

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
