services {
  name = "prometheus-podman-exporter-day1"
  id   = "prometheus-podman-exporter-workload"
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
    "blackbox-exporter",
    "metrics-exposing",
  ]
  meta = {
    scheme            = "https"
    address           = "prometheus-podman-exporter.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}