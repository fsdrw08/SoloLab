services {
  id      = "vault-web"
  name    = "vault"
  port    = 8200

  checks = [
    {
      id       = "vault-h2ping-check-8200"
      name     = "vault-h2ping-check-8200"
      h2ping   = "192.168.255.20:8200"
      tls_skip_verify = true
      interval = "20s"
      timeout  = "2s"
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