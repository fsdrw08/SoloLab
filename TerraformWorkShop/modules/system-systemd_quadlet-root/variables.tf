variable "vm_conn" {
  type = object({
    host        = string
    port        = number
    user        = string
    password    = optional(string, null)
    private_key = optional(string, null)
  })
}

variable "podman_quadlet" {
  type = object({
    files = list(
      object({
        content = string
        path    = string
      })
    )
    services = optional(
      list(object({
        name           = string
        status         = string
        custom_trigger = optional(string, "")
      })),
      null
    )
  })
}
