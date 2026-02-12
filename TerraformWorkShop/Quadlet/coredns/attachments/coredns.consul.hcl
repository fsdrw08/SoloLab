services {
  name = "coredns"
  id   = "coredns-server"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id       = "coredns-http-check"
      name     = "coredns-http-check"
      http     = "http://localhost:5380/health"
      interval = "300s"
      timeout  = "2s"
      status   = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]

  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "coredns.day0.sololab"
    prom_blackbox_health_check_path = "health"

    prom_target_scheme       = "https"
    prom_target_address      = "coredns.day0.sololab"
    prom_target_metrics_path = "metrics"
  }
}
