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
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "loki.day1.sololab"
    prom_blackbox_health_check_path = "ready"

    prom_target_scheme       = "https"
    prom_target_address      = "loki.day1.sololab"
    prom_target_metrics_path = "metrics"
  }
}