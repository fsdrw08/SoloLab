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
    corefile = object({
      content = string
    })
    snippets = optional(object({
      sub_dir = string
      # files = list(object({
      #   basename = string
      #   content  = string
      # }))
    }))
    dir = string
  })
}

variable "service" {
  type = object({
    status  = string
    enabled = bool
    systemd_unit_service = object({
      content     = string
      target_path = string
    })
  })
}
