# ref: https://github.com/marcusteixeira/home-ops/blob/9a71dcb4168f390642f88a1bde075c8d53e1745b/infrastructure/vyos/config/service-ssh.tf#L2
# set service dns forwarding domain consul server 192.168.255.2
resource "vyos_config_block" "dns_forwarding_consul" {
  path = "service dns forwarding domain consul"
  configs = {
    "server" = "192.168.255.2"
  }
}


# set service dns forwarding domain sololab server 192.168.255.2
resource "vyos_config_block" "dns_forwarding_sololab" {
  path = "service dns forwarding domain sololab"
  configs = {
    "server" = "192.168.255.2"
  }
}
