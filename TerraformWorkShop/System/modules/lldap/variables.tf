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
    tar_file_app_path = string
    app_pkg_dir       = string
  })
}

variable "runas" {
  type = object({
    user        = string
    group       = string
    take_charge = bool
  })
}

variable "config" {
  type = object({
    templatefile_path = string
    templatefile_vars = optional(map(string))
    tls = optional(object({
      ca_basename   = string
      ca_content    = string
      cert_basename = string
      cert_content  = string
      key_basename  = string
      key_content   = string
      sub_dir       = string
    }))
    env_templatefile_path = optional(string)
    env_templatefile_vars = optional(map(string))
    dir                   = string
  })
}

# variable "storage" {
#   type = object({
#     dir_target = string
#     dir_link   = string
#   })
# }

# variable "service" {
#   type = object({
#     status  = string
#     enabled = bool
#     systemd_unit_service = object({
#       templatefile_path = string
#       templatefile_vars = optional(map(string))
#       target_path       = string
#     })
#   })
# }
