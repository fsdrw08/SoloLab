services {
  name = "prometheus-consul-exporter"
  id   = "prometheus-consul-exporter-workload"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-consul-exporter-http-check"
      name            = "prometheus-consul-exporter-http-check"
      http            = "http://localhost:9107/"
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
    # "traefik.http.routers.prometheus-consul-exporter-redirect.entrypoints=web",
    # "traefik.http.routers.prometheus-consul-exporter-redirect.rule=Host(`prometheus-consul-exporter.day1.sololab`)",
    # "traefik.http.routers.prometheus-consul-exporter-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.prometheus-consul-exporter.entryPoints=webSecure",
    # "traefik.http.routers.prometheus-consul-exporter.rule=Host(`prometheus-consul-exporter.day1.sololab`)",
    # "traefik.http.routers.prometheus-consul-exporter.tls=true",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "prometheus-consul-exporter.day1.sololab"
    prom_blackbox_health_check_path = "metrics"

    prom_target_scheme       = "https"
    prom_target_address      = "prometheus-consul-exporter.day1.sololab"
    prom_target_metrics_path = "metrics"
  }
}