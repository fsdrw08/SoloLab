# ref: https://github.com/marcusteixeira/home-ops/blob/9a71dcb4168f390642f88a1bde075c8d53e1745b/infrastructure/vyos/config/service-ssh.tf#L2
# set service dns forwarding domain sololab server 192.168.255.2
resource "vyos_static_host_mapping" "cockroach" {
  host = "cockroach.day0.sololab"
  ip   = "192.168.255.1"
}

# https://serverfault.com/questions/1078467/how-to-force-a-specific-routing-based-on-sni-in-haproxy/1078563#1078563
resource "vyos_config_block_tree" "lb_svc_https_cockroach" {
  path = "load-balancing reverse-proxy service tcp443 rule 20"
  configs = {
    "ssl"         = "req-ssl-sni"
    "domain-name" = "cockroach.day0.sololab"
    "set backend" = "cockroach"
  }
}

resource "vyos_config_block_tree" "lb_be_cockroach" {
  path = "load-balancing reverse-proxy backend cockroach"
  configs = {
    "mode"                = "tcp"
    "server vyos address" = "192.168.255.1"
    "server vyos port"    = "5443"
  }
}
