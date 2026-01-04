services {
  name = "coredns-vyos"
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
    scheme            = "https"
    address           = "coredns.vyos.sololab"
    health_check_path = "health"
    metrics_path      = "metrics"
  }
}
