variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}

variable "volumes" {
  type = object({
    dynamic_host_volumes = optional(
      list(object({
        name = string
        capability = object({
          access_mode = optional(string, "single-node-writer")
        })
      })),
      []
    )
    csi_volume = optional(
      list(object({

      }))
    )
  })
}
