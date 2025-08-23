# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "nomad-day1"
  id   = "nomad-web"
  port = 4646

  checks = [
    {
      id              = "nomad-https-check"
      name            = "nomad-https-check"
      http            = "https://nomad.day1.sololab/v1/status/leader"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.http.routers.nomad-redirect.entrypoints=web",
  #   "traefik.http.routers.nomad-redirect.rule=Host(`nomad.day1.sololab`)",
  #   "traefik.http.routers.nomad-redirect.middlewares=toHttps@file",
  #   "traefik.http.routers.nomad.entrypoints=webSecure",
  #   "traefik.http.routers.nomad.rule=Host(`nomad.day1.sololab`)",
  #   "traefik.http.routers.nomad.tls=true",
  #   "traefik.http.services.nomad.loadBalancer.serversTransport=nomad@file",
  #   "traefik.http.services.nomad.loadbalancer.server.scheme=https",
  # ]
}
