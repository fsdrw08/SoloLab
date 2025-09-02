variable "vm_conn" {
  type = object({
    host        = string
    port        = number
    user        = string
    password    = optional(string, null)
    private_key = optional(string, null)
  })
}

variable "install" {
  type = list(object({
    zip_file_source = string
    zip_file_path   = string
    bin_file_name   = string
    bin_file_dir    = string
  }))
}

variable "runas" {
  type = object({
    take_charge = optional(bool, false)
    user        = string
    uid         = number
    group       = string
    gid         = string
  })
}

variable "config" {
  type = object({
    main = object({
      basename = string
      content  = string
    })
    tls = optional(object({
      ca_basename   = string
      ca_content    = string
      cert_basename = string
      cert_content  = string
      key_basename  = string
      key_content   = string
      sub_dir       = string
    }))
    env = optional(object({
      basename = string
      content  = string
    }))
    dir        = string
    create_dir = bool
  })
}

variable "service" {
  type = object({
    status = string
    auto_start = object({
      enabled     = bool
      link_path   = string
      link_target = string
    })
    systemd_service_unit = object({
      path    = string
      content = string
    })
  })
}
