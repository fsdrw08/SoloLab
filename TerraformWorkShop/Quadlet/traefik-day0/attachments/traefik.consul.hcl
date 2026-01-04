services {
  name = "traefik-day0"
  id   = "traefik-proxy"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id       = "traefik-http-check-8080"
      name     = "traefik-http-check-8080"
      http     = "http://localhost:8080/ping"
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
    address           = "traefik.day0.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}
