variable "prov_system" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "owner" {
  type = object({
    uid = number
    gid = number
  })
}

variable "config" {
  type = object({
    create_dir = bool
    dir        = string
    files = list(object({
      basename = string
      content  = string
      mode     = optional(number, null)
    }))
    secrets = optional(
      list(object({
        sub_dir = string
        files = list(object({
          basename = string
          content  = string
          mode     = optional(number, 600)
          })
        )
      })),
      []
    )
  })
}
