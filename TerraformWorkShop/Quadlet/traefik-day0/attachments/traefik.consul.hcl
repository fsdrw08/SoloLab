services {
  name = "traefik"
  id   = "traefik-day0-ping"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id       = "traefik-http-check-8080"
      name     = "traefik-http-check-8080"
      http     = "http://traefik.day0.sololab:8080/ping"
      interval = "300s"
      timeout  = "2s"
    }
  ]

  tags = [
    "exporter",
  ]
  meta = {
    scheme            = "https"
    address           = "traefik.day0.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}
