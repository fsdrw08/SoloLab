services {
  id      = "whoami-web"
  name    = "whoami"
  port    = 4646

  checks = [
    {
      id       = "whoami-tcp-check-4646"
      name     = "whoami-tcp-check-4646"
      tcp      = "192.168.255.20:4646"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    "traefik.tcp.routers.whoami-web.entrypoints=webSecure",
    "traefik.tcp.routers.whoami-web.rule=HostSNI(`whoami.day1.sololab`)",
    "traefik.tcp.routers.whoami-web.tls.passthrough=true",
    # "traefik.http.routers.whoami-web-redirect.entrypoints=web",
    # "traefik.http.routers.whoami-web-redirect.rule=Host(`whoami.day1.sololab`)",
    # "traefik.http.routers.whoami-web-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.whoami-web.entrypoints=websecure",
    # "traefik.http.routers.whoami-web.rule=Host(`whoami.day1.sololab`)",
    # "traefik.http.routers.whoami-web.tls=true",
    # "traefik.http.services.whoami-web.loadbalancer.server.scheme=https",
  ]
}
