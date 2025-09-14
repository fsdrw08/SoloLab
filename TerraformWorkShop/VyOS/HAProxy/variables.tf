variable "prov_vyos" {
  type = object({
    url = string
    key = string
  })
}

variable "reverse_proxy" {
  type = map(object({
    path    = string
    configs = map(string)
  }))
}
