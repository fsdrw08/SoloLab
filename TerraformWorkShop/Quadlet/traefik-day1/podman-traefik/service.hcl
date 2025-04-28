services {
  id   = "traefik-ping"
  name = "traefik"
  port = 8080

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id       = "traefik-http-check-8080"
      name     = "traefik-http-check-8080"
      http     = "http://traefik.day1.sololab:8080/ping"
      interval = "300s"
      timeout  = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.tcp.routers.nomad-web.entrypoints=webSecure",
  #   "traefik.tcp.routers.nomad-web.rule=HostSNI(`nomad.day1.sololab`)",
  #   "traefik.tcp.routers.nomad-web.tls.passthrough=true",
  #   # "traefik.http.routers.nomad-web-redirect.entrypoints=web",
  #   # "traefik.http.routers.nomad-web-redirect.rule=Host(`nomad.day1.sololab`)",
  #   # "traefik.http.routers.nomad-web-redirect.middlewares=toHttps@file",
  #   # "traefik.http.routers.nomad-web.entrypoints=websecure",
  #   # "traefik.http.routers.nomad-web.rule=Host(`nomad.day1.sololab`)",
  #   # "traefik.http.routers.nomad-web.tls=true",
  #   # "traefik.http.services.nomad-web.loadbalancer.server.scheme=https",
  # ]
}
