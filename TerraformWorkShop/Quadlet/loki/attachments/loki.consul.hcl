services {
  name = "loki-day1"
  id   = "loki-server"
  port = 443 # 3100

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "loki-https-check"
      name            = "loki-https-check"
      http            = "http://localhost:3100/ready"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "exporter",
  ]
  meta = {
    scheme            = "https"
    address           = "loki.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}