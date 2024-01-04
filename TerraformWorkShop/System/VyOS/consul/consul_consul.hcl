service {
  id      = "consul-ui"
  name    = "consul-ui"
  address = "consul-ui.service.consul"

  checks = [
    {
      id       = "consul-tcp-check-8500"
      name     = "consul-tcp-check-8500"
      tcp      = "192.168.255.2:8500"
      interval = "20s"
      timeout  = "2s"
    }
  ]

   tags = [
    "traefik.enable=true",
    "traefik.http.routers.consul-ui.rule=Host(`consul-ui.service.consul`)",
    "traefik.http.routers.consul-ui.entrypoints: websecure",
    "traefik.http.routers.consul-ui.middlewares: tohttps@file",
    "traefik.http.routers.consul-ui.tls.certresolver: internal",
    "traefik.http.services.consul-ui.loadbalancer.server.scheme=http",
    "traefik.http.services.consul-ui.loadbalancer.server.port=80"
  ]
}
