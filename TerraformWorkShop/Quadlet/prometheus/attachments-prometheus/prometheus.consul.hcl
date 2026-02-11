# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "prometheus"
  id   = "prometheus-server"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-http-check"
      name            = "prometheus-http-check"
      http            = "http://localhost:9090/-/healthy"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",

    # "traefik.enable=true",
    # "traefik.http.routers.prometheus-redirect.entrypoints=web",
    # "traefik.http.routers.prometheus-redirect.rule=Host(`prometheus.day1.sololab`)",
    # "traefik.http.routers.prometheus-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.prometheus.entryPoints=webSecure",
    # "traefik.http.routers.prometheus.rule=Host(`prometheus.day1.sololab`)",
    # "traefik.http.routers.prometheus.tls=true",
    # "traefik.http.services.prometheus.loadBalancer.serversTransport=prometheus@file",
    # "traefik.http.services.prometheus.loadbalancer.server.scheme=https",
  ]
  meta = {
    exporter_scheme       = "https"
    exporter_address      = "prometheus.day1.sololab"
    health_check_path     = "metrics"
    exporter_metrics_path = "metrics"
  }
}
