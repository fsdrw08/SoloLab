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
  type = object({
    zip_file_source = string
    zip_file_path   = string
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
    main = object({
      basename = string
      content  = string
    })
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
