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
    exporter_scheme       = "https"
    exporter_address      = "coredns.day0.sololab"
    health_check_path     = "health"
    exporter_metrics_path = "metrics"
  }
}
