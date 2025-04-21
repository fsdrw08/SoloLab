services {
  id   = "vault-web"
  name = "vault"
  port = 8200

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "vault-https-check"
      name            = "vault-https-check"
      http            = "https://vault.day0.sololab/v1/sys/health"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.tcp.routers.vault-web.entrypoints=webSecure",
  #   "traefik.tcp.routers.vault-web.rule=HostSNI(`vault.day1.sololab`)",
  #   "traefik.tcp.routers.vault-web.tls.passthrough=true",
  #   # "traefik.http.routers.vault-web-redirect.entrypoints=web",
  #   # "traefik.http.routers.vault-web-redirect.rule=Host(`vault.day1.sololab`)",
  #   # "traefik.http.routers.vault-web-redirect.middlewares=toHttps@file",
  #   # "traefik.http.routers.vault-web.entrypoints=websecure",
  #   # "traefik.http.routers.vault-web.rule=Host(`vault.day1.sololab`)",
  #   # "traefik.http.routers.vault-web.tls=true",
  #   # "traefik.http.services.vault-web.loadbalancer.server.scheme=https",
  # ]
}