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
    "traefik.enable=true",
    "traefik.http.routers.alloy-redirect.entrypoints=web",
    "traefik.http.routers.alloy-redirect.rule=Host(`alloy.day1.sololab`)",
    "traefik.http.routers.alloy-redirect.middlewares=toHttps@file",
    "traefik.http.routers.alloy.entrypoints=webSecure",
    "traefik.http.routers.alloy.rule=Host(`alloy.day1.sololab`)",
    "traefik.http.routers.alloy.tls=true",
    "traefik.http.services.alloy.loadBalancer.serversTransport=alloy@file",
    "traefik.http.services.alloy.loadbalancer.server.scheme=https",
  ]
}
