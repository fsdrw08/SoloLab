services {
  id   = "consul-web"
  name = "consul-client"
  port = 8501

  checks = [
    {
      id              = "consul-https-check"
      name            = "consul-https-check"
      http            = "https://consul-client.day0.sololab/v1/status/leader"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.tcp.routers.consul-web.entrypoints=webSecure",
  #   "traefik.tcp.routers.consul-web.rule=HostSNI(`consul.day1.sololab`)",
  #   "traefik.tcp.routers.consul-web.tls.passthrough=true",
  #   # "traefik.http.routers.consul-web-redirect.entrypoints=web",
  #   # "traefik.http.routers.consul-web-redirect.rule=Host(`consul.day1.sololab`)",
  #   # "traefik.http.routers.consul-web-redirect.middlewares=toHttps@file",
  #   # "traefik.http.routers.consul-web.entrypoints=webSecure",
  #   # "traefik.http.routers.consul-web.rule=Host(`consul.day1.sololab`)",
  #   # "traefik.http.routers.consul-web.tls=true",
  #   # "traefik.http.services.consul-web.loadbalancer.server.scheme=https",
  # ]
}