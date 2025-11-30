variable "prov_system" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "prov_vyos" {
  type = object({
    url = string
    key = string
  })
}

variable "service_monitoring" {
  type = map(object({
    path    = string
    configs = map(string)
  }))
}

variable "reverse_proxy" {
  type = map(object({
    path    = string
    configs = map(string)
  }))
}
