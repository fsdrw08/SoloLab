variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "systemd_unit_files" {
  type = list(object({
    path    = string
    content = string
  }))
}

variable "systemd_unit_name" {
  type    = string
  default = ""
}
