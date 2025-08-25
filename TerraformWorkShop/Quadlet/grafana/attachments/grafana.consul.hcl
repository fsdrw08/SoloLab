# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "grafana-day1"
  id   = "grafana-server"
  port = 3000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "grafana-https-check"
      name            = "grafana-https-check"
      http            = "https://localhost:3000/api/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "traefik-day1.enable=true",
    "traefik-day1.http.routers.grafana-redirect.entrypoints=web",
    "traefik-day1.http.routers.grafana-redirect.rule=Host(`grafana.day1.sololab`)",
    "traefik-day1.http.routers.grafana-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.grafana.entrypoints=webSecure",
    "traefik-day1.http.routers.grafana.rule=Host(`grafana.day1.sololab`)",
    "traefik-day1.http.routers.grafana.tls=true",
    "traefik-day1.http.services.grafana.loadBalancer.serversTransport=grafana@file",
    "traefik-day1.http.services.grafana.loadbalancer.server.scheme=https",
  ]
}