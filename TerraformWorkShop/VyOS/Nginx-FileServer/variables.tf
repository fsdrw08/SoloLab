variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "reverse_proxy" {
  type = map(object({
    path    = string
    configs = map(string)
  }))
}

variable "dns_record" {
  type = object({
    host = string
    ip   = string
  })
}
