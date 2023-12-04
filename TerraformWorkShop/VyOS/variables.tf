variable "vyos_conn" {
  type = object({
    address      = string
    api_port     = string
    api_key      = string
    ssh_user     = string
    ssh_password = string
  })
  default = {
    address      = "192.168.255.1"
    api_port     = "8443"
    api_key      = "MY-HTTPS-API-PLAINTEXT-KEY"
    ssh_user     = "vyos"
    ssh_password = "vyos"
  }
}
