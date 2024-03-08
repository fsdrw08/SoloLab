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

variable "runas" {
  type = object({
    take_charge = optional(bool, false)
    user        = string
    group       = string
  })
}

variable "config" {
  type = object({
    env = object({
      templatefile_path = string
      templatefile_vars = optional(map(string))
    })
    certs = optional(object({
      ca_basename  = string
      ca_content   = string
      cert_content = string
      key_content  = string
      sub_dir      = string
    }))
    dir = string
  })
}

variable "service" {
  type = object({
    status  = string
    enabled = bool
    systemd_unit_service = object({
      templatefile_path = string
      templatefile_vars = optional(map(string))
      target_path       = string
    })
  })
}
