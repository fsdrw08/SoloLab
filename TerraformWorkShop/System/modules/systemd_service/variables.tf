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
