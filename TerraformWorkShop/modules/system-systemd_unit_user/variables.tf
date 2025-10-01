variable "vm_conn" {
  type = object({
    host        = string
    port        = number
    user        = string
    password    = optional(string, null)
    private_key = optional(string, null)
  })
}

variable "runas" {
  type = object({
    take_charge = optional(bool, false)
    user        = string
    uid         = number
    group       = string
    gid         = number
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
