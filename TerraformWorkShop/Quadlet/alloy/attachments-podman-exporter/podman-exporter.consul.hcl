services {
  name = "prometheus-podman-exporter"
  id   = "prometheus-podman-exporter-day1"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-podman-exporter-http-check"
      name            = "prometheus-podman-exporter-http-check"
      http            = "https://prometheus-podman-exporter.day1.sololab/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  tags = [
    "exporter",
  ]
  meta = {
    scheme            = "https"
    address           = "prometheus-podman-exporter.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}