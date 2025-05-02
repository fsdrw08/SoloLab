services {
  id   = "traefik-ping"
  name = "traefik"
  port = 8080

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
}
