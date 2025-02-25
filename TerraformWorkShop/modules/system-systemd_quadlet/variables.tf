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
    service = object({
      name   = string
      status = string
    })
    files = list(
      object({
        content = string
        path    = string
      })
    )
  })
}
