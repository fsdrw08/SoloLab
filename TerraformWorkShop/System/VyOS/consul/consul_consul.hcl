// https://developer.hashicorp.com/consul/docs/services/configuration/services-configuration-reference
services {
  id      = "consul-internal"
  name    = "consul-internal"
  address = "127.0.0.1"
  port    = 8500

  checks = [
    {
      id       = "consul-tcp-check-8500"
      name     = "consul-tcp-check-8500"
      tcp      = "127.0.0.1:8500"
      interval = "20s"
      timeout  = "2s"
    }
  ]

   tags = [
    "traefik.enable=true",
    "traefik.http.routers.consul-redirect.rule=Host(`consul-ui.service.consul`)",
    "traefik.http.routers.consul-redirect.entrypoints=web",
    "traefik.http.routers.consul-redirect.middlewares=toHttps@file",
    "traefik.http.routers.consul.rule=Host(`consul-ui.service.consul`)",
    "traefik.http.routers.consul.entrypoints=websecure",
    "traefik.http.routers.consul.tls.certresolver=internal",
    "traefik.http.services.consul.loadbalancer.server.scheme=http",
    // "traefik.http.services.consul.loadbalancer.server.port=8500"
  ]
}

services {
  id      = "consul-external"
  name    = "consul-ui"
  address = "192.168.255.2"
}
