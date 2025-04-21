services {
  id   = "zot-web"
  name = "zot"
  port = 5000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "zot-https-check"
      name            = "zot-https-check"
      http            = "https://zot.day0.sololab/v2/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
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
