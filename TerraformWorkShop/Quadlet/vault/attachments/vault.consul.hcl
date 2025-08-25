# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "vault-day1"
  id   = "vault-server"
  port = 8200

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "vault-https-check"
      name            = "vault-https-check"
      http            = "https://localhost:8200/v1/sys/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "vault-exporter",

    "traefik-day1.enable=true",
    "traefik-day1.http.routers.vault-redirect.entrypoints=web",
    "traefik-day1.http.routers.vault-redirect.rule=Host(`vault.day1.sololab`)",
    "traefik-day1.http.routers.vault-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.vault.entrypoints=webSecure",
    "traefik-day1.http.routers.vault.rule=Host(`vault.day1.sololab`)",
    "traefik-day1.http.routers.vault.tls=true",
    "traefik-day1.http.services.vault.loadBalancer.serversTransport=vault@file",
    "traefik-day1.http.services.vault.loadbalancer.server.scheme=https",
  ]

  meta = {
    scheme                    = "https"
    address                   = "vault.day1.sololab"
    health_check_path         = "v1/sys/health"
    metrics_path              = "v1/sys/metrics"
    metrics_path_param_format = "prometheus"
  }
}