services {
  id      = "consul-web"
  name    = "consul"
  port    = 8500

  checks = [
    {
      id       = "consul-web-tcp-check-8500"
      name     = "consul-web-tcp-check-8500"
      tcp      = "localhost:8500"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    // "traefik.tcp.routers.consul-web.entrypoints=webSecure",
    // "traefik.tcp.routers.consul-web.rule=HostSNI(`consul.day1.sololab`)",
    // "traefik.tcp.routers.consul-web.tls.passthrough=true",
    "traefik.http.routers.consul-web-redirect.entrypoints=web",
    "traefik.http.routers.consul-web-redirect.rule=Host(`consul.day1.sololab`)",
    "traefik.http.routers.consul-web-redirect.middlewares=toHttps@file",
    "traefik.http.routers.consul-web.entrypoints=webSecure",
    "traefik.http.routers.consul-web.rule=Host(`consul.day1.sololab`)",
    "traefik.http.routers.consul-web.tls=true",
    "traefik.http.services.consul-web.loadbalancer.server.scheme=https",
  ]
}