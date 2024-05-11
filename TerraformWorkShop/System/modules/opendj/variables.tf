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
    zip_file_source = string
    zip_file_path   = string
    unzip_dir       = string
  })
}

variable "runas" {
  type = object({
    take_charge = bool
    user        = optional(string, null)
    group       = optional(string, null)
    uid         = number
    gid         = number
  })
}

variable "config" {
  type = object({
    properties = optional(object({
      basename = string
      content  = string
    }))
    schema = optional(object({
      ldif = list(object({
        basename = string
        content  = string
      }))
      sub_dir = string
    }))
    certs = optional(object({
      basename = string
      source   = string
      sub_dir  = string
    }))
    dir = string
  })
}

variable "storage" {
  type = object({
    dir_target = string
    dir_link   = string
  })
}
