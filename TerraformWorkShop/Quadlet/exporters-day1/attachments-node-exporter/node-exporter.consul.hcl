services {
  name = "prometheus-node-exporter-day1"
  id   = "prometheus-node-exporter-workload"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-node-exporter-http-check"
      name            = "prometheus-node-exporter-http-check"
      http            = "http://localhost:9100/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]
  meta = {
    scheme            = "https"
    address           = "prometheus-node-exporter.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}