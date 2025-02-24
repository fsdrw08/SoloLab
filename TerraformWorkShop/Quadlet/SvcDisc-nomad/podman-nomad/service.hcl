services {
  id      = "nomad-web"
  name    = "nomad"
  port    = 4646

  checks = [
    {
      id       = "nomad-tcp-check-4646"
      name     = "nomad-tcp-check-4646"
      tcp      = "192.168.255.20:4646"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    "traefik.tcp.routers.nomad-web.entrypoints=webSecure",
    "traefik.tcp.routers.nomad-web.rule=HostSNI(`nomad.day1.sololab`)",
    "traefik.tcp.routers.nomad-web.tls.passthrough=true",
    # "traefik.http.routers.nomad-web-redirect.entrypoints=web",
    # "traefik.http.routers.nomad-web-redirect.rule=Host(`nomad.day1.sololab`)",
    # "traefik.http.routers.nomad-web-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.nomad-web.entrypoints=websecure",
    # "traefik.http.routers.nomad-web.rule=Host(`nomad.day1.sololab`)",
    # "traefik.http.routers.nomad-web.tls=true",
    # "traefik.http.services.nomad-web.loadbalancer.server.scheme=https",
  ]
}
