# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "grafana"
  id   = "grafana-server"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "grafana-http-check"
      name            = "grafana-http-check"
      http            = "http://localhost:3000/api/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "grafana.day1.sololab"
    prom_blackbox_health_check_path = "api/health"
  }
}