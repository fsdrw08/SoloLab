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

variable "csi_volumes" {
  type = list(object({
    name      = string
    plugin_id = string
    volume_id = string
    capabilities = list(object({
      access_mode     = string
      attachment_mode = string
    }))
    capacity_min = optional(string, null)
    capacity_max = optional(string, null)
    parameters   = optional(map(string), null)
    mount_options = optional(
      object({
        fs_type     = optional(string, null)
        mount_flags = optional(list(string), null)
      }),
      null
    )
  }))
  default = []
}
