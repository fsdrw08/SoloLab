services {
  id      = "traefik-web"
  name    = "traefik"
  port    = 80

  checks = [
    {
      id       = "traefik-web-tcp-check-8500"
      name     = "traefik-web-tcp-check-8500"
      tcp      = "localhost:8500"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    // "traefik.tcp.routers.traefik-web.entrypoints=webSecure",
    // "traefik.tcp.routers.traefik-web.rule=HostSNI(`traefik.day1.sololab`)",
    // "traefik.tcp.routers.traefik-web.tls.passthrough=true",
    "traefik.http.routers.traefik-web-redirect.entrypoints=web",
    "traefik.http.routers.traefik-web-redirect.rule=Host(`traefik.day1.sololab`)",
    "traefik.http.routers.traefik-web-redirect.middlewares=toHttps@file",
    "traefik.http.routers.traefik-web.entrypoints=webSecure",
    "traefik.http.routers.traefik-web.rule=Host(`traefik.day1.sololab`)",
    "traefik.http.routers.traefik-web.tls=true",
    "traefik.http.services.traefik-web.loadbalancer.server.scheme=https",
  ]
}