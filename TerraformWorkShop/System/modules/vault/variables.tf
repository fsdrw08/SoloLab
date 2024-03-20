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
    bin_file_dir    = string
  })
}

variable "runas" {
  type = object({
    user  = string
    group = string
  })
}

variable "storage" {
  type = object({
    dir_target = string
    dir_link   = string
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
    dir = string
  })
}

variable "service" {
  type = object({
    status  = string
    enabled = bool
    systemd_service_unit = object({
      path    = string
      content = string
    })
  })
}
