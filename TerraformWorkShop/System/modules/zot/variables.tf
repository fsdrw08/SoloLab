variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "runas" {
  type = object({
    take_charge = optional(bool, false)
    user        = optional(string, null)
    uid         = optional(number, null)
    group       = optional(string, null)
    gid         = optional(number, null)
  })
}

variable "install" {
  type = object({
    server = object({
      bin_file_dir    = string
      bin_file_source = string
    })
    client = optional(object({
      bin_file_dir    = string
      bin_file_source = string
    }))
  })
}

variable "config" {
  type = object({
    main = object({
      basename = string
      content  = string
    })
    certs = optional(object({
      cert_basename = string
      cert_content  = string
      key_basename  = string
      key_content   = string
      sub_dir       = string
    }))
    dir = string
  })
}
