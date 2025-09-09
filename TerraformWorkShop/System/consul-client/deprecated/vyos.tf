# set service dns forwarding domain consul server 192.168.255.2
resource "vyos_config_block" "dns_forwarding_consul" {
  path = "service dns forwarding domain consul"
  configs = {
    "server" = "192.168.255.2"
  }
}

