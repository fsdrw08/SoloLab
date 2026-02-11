services {
  name = "prometheus-node-exporter-vyos"
  id   = "prometheus-node-exporter-workload"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-node-exporter-http-check"
      name            = "prometheus-node-exporter-http-check"
      http            = "http://127.0.0.1:9100/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "blackbox-exporter",
    "metrics-exposing-general",
  ]
  meta = {
    exporter_scheme       = "https"
    exporter_address      = "prometheus-node-exporter.vyos.sololab"
    health_check_path     = "metrics"
    exporter_metrics_path = "metrics"
  }
}
