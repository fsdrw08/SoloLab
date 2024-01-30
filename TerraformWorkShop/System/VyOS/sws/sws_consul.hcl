service {
  id      = "sws-internal"
  name    = "sws"
  address = "127.0.0.1"
  port    = 80

  checks = [
    {
      id       = "sws-tcp-check-80"
      name     = "sws-tcp-check-80"
      tcp      = "127.0.0.1:80"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.sws-redirect.rule=Host(`sws.service.consul`)",
    "traefik.http.routers.sws-redirect.entrypoints=web",
    "traefik.http.routers.sws-redirect.middlewares=toHttps@file",
    "traefik.http.routers.sws.rule=Host(`sws.service.consul`)",
    "traefik.http.routers.sws.entrypoints=websecure",
    "traefik.http.routers.sws.tls.certresolver=internal",
    "traefik.http.services.sws.loadbalancer.server.scheme=http",
  ]
}

services {
  id      = "sws-external"
  name    = "sws"
}
