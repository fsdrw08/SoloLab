variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "install" {
  type = object({
    tar_file_source = string
    tar_file_path   = string
    bin_file_dir    = string
  })
  default = null
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
    })
    tls = optional(
      object({
        ca_basename   = optional(string, null)
        ca_content    = optional(string, null)
        cert_basename = string
        cert_content  = string
        key_basename  = string
        key_content   = string
        sub_dir       = string
      }),
      null
    )
  })
}
