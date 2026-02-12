services {
  name = "alloy-day1"
  id   = "alloy-web"
  port = 443 # 12345

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "alloy-http-check"
      name            = "alloy-http-check"
      http            = "http://localhost:12345/-/healthy"
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
    prom_blackbox_address           = "alloy.day1.sololab"
    prom_blackbox_health_check_path = "-/healthy"
  }
}
