# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "grafana"
  id   = "grafana-server"
  port = 3000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "grafana-http-check"
      name            = "grafana-http-check"
      http            = "http://localhost:3000/api/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.http.routers.grafana-redirect.entrypoints=web",
  #   "traefik.http.routers.grafana-redirect.rule=Host(`grafana.day1.sololab`)",
  #   "traefik.http.routers.grafana-redirect.middlewares=toHttps@file",
  #   "traefik.http.routers.grafana.entrypoints=webSecure",
  #   "traefik.http.routers.grafana.rule=Host(`grafana.day1.sololab`)",
  #   "traefik.http.routers.grafana.tls=true",
  # ]
}