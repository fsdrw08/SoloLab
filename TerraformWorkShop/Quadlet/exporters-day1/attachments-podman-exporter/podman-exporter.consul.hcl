services {
  name = "prometheus-podman-exporter"
  id   = "prometheus-podman-exporter-day1"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-podman-exporter-http-check"
      name            = "prometheus-podman-exporter-http-check"
      http            = "http://localhost:9882/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "day1",
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "day1.prometheus-podman-exporter.service.consul"
    prom_blackbox_health_check_path = "metrics"

    prom_target_scheme       = "https"
    prom_target_address      = "day1.prometheus-podman-exporter.service.consul"
    prom_target_metrics_path = "metrics"
  }
}