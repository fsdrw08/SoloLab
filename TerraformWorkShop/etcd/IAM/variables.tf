variable "prov_etcd" {
  type = object({
    endpoints = string
    ca_cert   = optional(string, null)
    username  = string
    password  = string
    skip_tls  = bool
  })
}

variable "roles" {
  type = list(object({
    name = string
    permissions = list(object({
      permission = string
      key        = string
      range_end  = optional(string, null)
    }))
  }))
}

variable "users" {
  type = list(object({
    username = string
    password = string
    roles    = list(string)
  }))
}