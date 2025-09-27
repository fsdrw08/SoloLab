variable "prov_remote" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "podman_quadlet" {
  type = object({
    dir = string
    units = list(object({
      files = list(object({
        template = string
        vars     = map(string)
      }))
      service = optional(
        object({
          name   = string
          status = string
        }),
        null
      )
    }))
  })
}

variable "post_process" {
  type = map(object({
    script_path = string
    vars        = map(string)
  }))
  default = null
}
