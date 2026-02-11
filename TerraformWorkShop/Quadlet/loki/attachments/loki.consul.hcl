services {
  name = "loki"
  id   = "loki-server"
  port = 443 # 3100

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "loki-http-check"
      name            = "loki-http-check"
      http            = "http://localhost:3100/ready"
      tls_skip_verify = true
      interval        = "30s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]
  meta = {
    exporter_scheme       = "https"
    exporter_address      = "loki.day1.sololab"
    health_check_path     = "ready"
    exporter_metrics_path = "metrics"
  }
}