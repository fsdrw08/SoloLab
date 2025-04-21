services {
  id   = "cockpit-web"
  name = "cockpit"
  port = 9000

  checks = [
    # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
    {
      id   = "cockpit-https-check"
      name = "cockpit-https-check"
      # https://cockpit-project.org/guide/latest/https.html
      http            = "https://cockpit.day0.sololab/ping"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.tcp.routers.cockpit-web.entrypoints=webSecure",
  #   "traefik.tcp.routers.cockpit-web.rule=HostSNI(`cockpit.day1.sololab`)",
  #   "traefik.tcp.routers.cockpit-web.tls.passthrough=true",
  #   # "traefik.http.routers.cockpit-web-redirect.entrypoints=web",
  #   # "traefik.http.routers.cockpit-web-redirect.rule=Host(`cockpit.day1.sololab`)",
  #   # "traefik.http.routers.cockpit-web-redirect.middlewares=toHttps@file",
  #   # "traefik.http.routers.cockpit-web.entrypoints=websecure",
  #   # "traefik.http.routers.cockpit-web.rule=Host(`cockpit.day1.sololab`)",
  #   # "traefik.http.routers.cockpit-web.tls=true",
  #   # "traefik.http.services.cockpit-web.loadbalancer.server.scheme=https",
  # ]
}