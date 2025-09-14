prov_system = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

prov_vyos = {
  url = "https://api.vyos.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

# reverse_proxy = {
#   web_frontend = {
#     # path = "load-balancing reverse-proxy service tcp443 rule 50" # vyos 1.4
#     path = "load-balancing haproxy service tcp443 rule 50" # vyos 1.5
#     configs = {
#       "ssl"         = "req-ssl-sni"
#       "domain-name" = "cockpit.day0.sololab"
#       "set backend" = "cockpit_web"
#     }
#   }
#   web_backend = {
#     path = "load-balancing haproxy backend cockpit_web"
#     configs = {
#       "mode"                = "tcp"
#       "server vyos address" = "172.16.5.10"
#       "server vyos port"    = "9090"
#     }
#   }
# }
