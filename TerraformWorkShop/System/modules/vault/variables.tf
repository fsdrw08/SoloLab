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
    file_source = string
    vars        = optional(map(string))
    tls = optional(object({
      ca_basename   = string
      ca_content    = string
      cert_basename = string
      cert_content  = string
      key_basename  = string
      key_content   = string
    }))
    file_path_dir = string
  })
}

variable "service" {
  type = object({
    status  = string
    enabled = bool
    systemd_unit_service = object({
      file_source = string
      file_path   = string
      vars        = optional(map(string))
    })
  })
}
