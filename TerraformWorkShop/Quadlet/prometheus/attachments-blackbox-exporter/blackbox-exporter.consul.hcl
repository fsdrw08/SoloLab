services {
  name = "prometheus-blackbox-exporter"
  id   = "prometheus-blackbox-exporter-workload"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-blackbox-exporter-http-check"
      name            = "prometheus-blackbox-exporter-http-check"
      http            = "http://localhost:9115/-/healthy"
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
    # "traefik.http.routers.prometheus-blackbox-exporter-redirect.entrypoints=web",
    # "traefik.http.routers.prometheus-blackbox-exporter-redirect.rule=Host(`prometheus-blackbox-exporter.day1.sololab`)",
    # "traefik.http.routers.prometheus-blackbox-exporter-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.prometheus-blackbox-exporter.entryPoints=webSecure",
    # "traefik.http.routers.prometheus-blackbox-exporter.rule=Host(`prometheus-blackbox-exporter.day1.sololab`)",
    # "traefik.http.routers.prometheus-blackbox-exporter.tls=true",
  ]
  meta = {
    scheme            = "https"
    address           = "prometheus-blackbox-exporter.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}