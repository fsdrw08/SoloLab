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
    tar_file_source   = string
    tar_file_path     = string
    tar_file_bin_path = string
    bin_file_dir      = string
  })
}

variable "runas" {
  type = object({
    take_charge = optional(bool, false)
    user        = string
    group       = string
  })
}

variable "config" {
  type = object({
    main = object({
      basename = string
      content  = string
    })
    tls = optional(object({
      cert_basename = optional(string)
      cert_content  = optional(string)
      key_basename  = optional(string)
      key_content   = optional(string)
      sub_dir       = string
    }))
    dir = string
  })
}

variable "service" {
  type = object({
    status  = string
    enabled = bool
    systemd_service_unit = object({
      content = string
      path    = string
    })
  })
}
