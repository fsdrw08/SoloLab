variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "systemd_path_unit" {
  type = object({
    path    = string
    content = string
    enabled = bool
  })
}

variable "systemd_service_unit" {
  type = object({
    path    = string
    content = string
  })
}
