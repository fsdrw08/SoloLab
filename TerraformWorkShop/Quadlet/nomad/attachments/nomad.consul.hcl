# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "nomad"
  id   = "nomad-agent"
  port = 4646

  checks = [
    {
      id              = "nomad-https-check"
      name            = "nomad-https-check"
      http            = "https://localhost:4646/v1/status/leader"
      tls_skip_verify = true
      interval        = "30s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",

    "traefik.enable=true",
    "traefik.http.routers.nomad-redirect.entrypoints=web",
    "traefik.http.routers.nomad-redirect.rule=Host(`nomad.day1.sololab`)||Host(`nomad.service.consul`)",
    "traefik.http.routers.nomad-redirect.middlewares=toHttps@file",
    "traefik.http.routers.nomad.entrypoints=webSecure",
    "traefik.http.routers.nomad.rule=Host(`nomad.day1.sololab`)||Host(`nomad.service.consul`)",
    "traefik.http.routers.nomad.tls=true",
    "traefik.http.services.nomad.loadBalancer.serversTransport=sololab-day1@file",
    "traefik.http.services.nomad.loadbalancer.server.scheme=https",
  ]
  meta = {
    scheme                    = "https"
    address                   = "nomad.day1.sololab"
    health_check_path         = "v1/status/leader"
    metrics_path              = "v1/metrics"
    metrics_path_param_format = "prometheus"
  }
}
