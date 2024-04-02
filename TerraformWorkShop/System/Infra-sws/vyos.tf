# ref: https://github.com/marcusteixeira/home-ops/blob/9a71dcb4168f390642f88a1bde075c8d53e1745b/infrastructure/vyos/config/service-ssh.tf#L2
# set service dns forwarding domain sololab server 192.168.255.2
resource "vyos_static_host_mapping" "sws" {
  host = "sws.core.sololab"
  ip   = "192.168.255.1"
}

resource "vyos_config_block_tree" "lb_svc_https_sws" {
  path = "load-balancing reverse-proxy service http rule 20"
  configs = {
    "domain-name" = "sws.core.sololab"
    "set backend" = "sws"
  }
}

resource "vyos_config_block_tree" "lb_be_sws" {
  path = "load-balancing reverse-proxy backend sws"
  configs = {
    "mode"                = "http"
    "server vyos address" = "192.168.255.1"
    "server vyos port"    = "4080"
  }
}
