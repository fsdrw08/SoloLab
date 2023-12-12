variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "consul_conn" {
  type = object({
    address    = string
    datacenter = string
    scheme     = optional(string)
  })
}
variable "consul_version" {
  type    = string
  default = "1.17.0"
}

variable "consul_token_mgmt" {
  type = string
}
