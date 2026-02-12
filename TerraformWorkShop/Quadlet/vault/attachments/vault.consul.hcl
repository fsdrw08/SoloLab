# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "vault"
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
    "metrics-exposing-vault",
    "metrics-exposing-blackbox",

    # "traefik.enable=true",
    # "traefik.http.routers.vault-redirect.entrypoints=web",
    # "traefik.http.routers.vault-redirect.rule=Host(`vault.day0.sololab`) || Host(`vault.service.consul`)",
    # "traefik.http.routers.vault-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.vault.entrypoints=webSecure",
    # "traefik.http.routers.vault.rule=Host(`vault.day0.sololab`) || Host(`vault.service.consul`)",
    # "traefik.http.routers.vault.tls=true",
    # "traefik.http.services.vault.loadBalancer.serversTransport=sololab-day0@file",
    # "traefik.http.services.vault.loadbalancer.server.scheme=https",
  ]

  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "vault.day0.sololab"
    prom_blackbox_health_check_path = "v1/sys/health"

    prom_target_scheme                    = "https"
    prom_target_address                   = "vault.day0.sololab"
    prom_target_metrics_path              = "v1/sys/metrics"
    prom_target_metrics_path_param_format = "prometheus"
  }
}