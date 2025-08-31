services {
  name = "coredns-day0"
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
    "exporter",
  ]

  meta = {
    scheme            = "https"
    address           = "coredns.day0.sololab"
    health_check_path = "health"
    metrics_path      = "metrics"
  }
}
