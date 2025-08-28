variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}
variable "dynamic_host_volumes" {
  type = list(object({
    name = string
    capability = object({
      access_mode = optional(string, "single-node-writer")
    })
  }))
}
