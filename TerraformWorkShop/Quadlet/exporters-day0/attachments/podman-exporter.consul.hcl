services {
  name = "prometheus-podman-exporter-day0"
  id   = "prometheus-podman-exporter-workload"
  port = 9882

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
    "exporter",
  ]
  meta = {
    scheme            = "http"
    address           = "prometheus-podman-exporter.day0.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}