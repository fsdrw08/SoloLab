# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "nomad-day1"
  id   = "nomad-agent"
  port = 4646

  checks = [
    {
      id              = "nomad-https-check"
      name            = "nomad-https-check"
      http            = "https://localhost:4646/v1/status/leader"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "traefik-day1.enable=true",
    "traefik-day1.http.routers.nomad-redirect.entrypoints=web",
    "traefik-day1.http.routers.nomad-redirect.rule=Host(`nomad.day1.sololab`)",
    "traefik-day1.http.routers.nomad-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.nomad.entrypoints=webSecure",
    "traefik-day1.http.routers.nomad.rule=Host(`nomad.day1.sololab`)",
    "traefik-day1.http.routers.nomad.tls=true",
    "traefik-day1.http.services.nomad.loadBalancer.serversTransport=nomad@file",
    "traefik-day1.http.services.nomad.loadbalancer.server.scheme=https",
  ]
}
