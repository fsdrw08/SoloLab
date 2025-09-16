variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "install" {
  type    = list(string)
  default = []
}

variable "runas" {
  type = object({
    take_charge = optional(bool, false)
    user        = string
    uid         = number
    group       = string
    gid         = number
  })
}

variable "config" {
  type = object({
    create_dir = bool
    dir        = string
    main = object({
      basename = string
      content  = string
      mode     = number
    })
  })
}
