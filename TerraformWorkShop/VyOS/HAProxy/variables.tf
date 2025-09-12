variable "prov_vyos" {
  type = object({
    url = string
    key = string
  })
}

variable "services" {
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
