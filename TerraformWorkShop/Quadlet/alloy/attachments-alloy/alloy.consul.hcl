services {
  name = "alloy-day1"
  id   = "alloy-web"
  port = 12345

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "alloy-https-check"
      name            = "alloy-https-check"
      http            = "https://localhost:12345/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "traefik-day1.enable=true",
    "traefik-day1.http.routers.alloy-redirect.entrypoints=web",
    "traefik-day1.http.routers.alloy-redirect.rule=Host(`alloy.day1.sololab`)",
    "traefik-day1.http.routers.alloy-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.alloy.entrypoints=webSecure",
    "traefik-day1.http.routers.alloy.rule=Host(`alloy.day1.sololab`)",
    "traefik-day1.http.routers.alloy.tls=true",
    "traefik-day1.http.services.alloy.loadBalancer.serversTransport=alloy@file",
    "traefik-day1.http.services.alloy.loadbalancer.server.scheme=https",
  ]
}
