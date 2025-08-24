services {
  name = "consul-day1"
  id   = "consul-agent"
  port = 8501

  checks = [
    {
      id              = "consul-https-check"
      name            = "consul-https-check"
      http            = "https://localhost:8501/v1/status/leader"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.http.routers.consul-redirect.entrypoints=web",
  #   "traefik.http.routers.consul-redirect.rule=Host(`consul-client.day0.sololab`)",
  #   "traefik.http.routers.consul-redirect.middlewares=toHttps@file",
  #   "traefik.http.routers.consul.entrypoints=webSecure",
  #   "traefik.http.routers.consul.rule=Host(`consul-client.day0.sololab`)",
  #   "traefik.http.routers.consul.tls=true",
  #   "traefik.http.services.consul.loadBalancer.serversTransport=consul@file",
  #   "traefik.http.services.consul.loadbalancer.server.scheme=https",
  # ]
}