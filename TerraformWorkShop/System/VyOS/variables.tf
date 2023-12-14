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

variable "consul_conf" {
  type = object({
    data_dir    = string
    client_addr = string
    bind_addr   = string
  })
}

variable "consul_token_mgmt" {
  type = string
}

variable "stepca_version" {
  type        = string
  description = "https://github.com/smallstep/certificates/releases"
  default     = "0.25.2"
}

variable "stepcli_version" {
  type        = string
  description = "https://github.com/smallstep/cli/releases"
  default     = "0.25.2"
}

variable "stepca_password" {
  type = string
}

variable "traefik_version" {
  type = string
}
