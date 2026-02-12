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
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "prometheus-node-exporter.vyos.sololab"
    prom_blackbox_health_check_path = "metrics"

    prom_target_scheme       = "https"
    prom_target_address      = "prometheus-node-exporter.vyos.sololab"
    prom_target_metrics_path = "metrics"
    health_check_path        = "metrics"
  }
}
