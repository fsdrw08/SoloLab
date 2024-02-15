services {
  id      = "vault-internal-api"
  name    = "vault"
  address = "127.0.0.1"
  port    = 8200

  checks = [
    {
      id       = "vault-api-tcp-check-8200"
      name     = "vault-api-tcp-check-8200"
      tcp      = "127.0.0.1:8200"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    "traefik.tcp.routers.vault-api.entrypoints=websecure",
    "traefik.tcp.routers.vault-api.rule=HostSNI(`vault.service.consul`)",
    "traefik.tcp.routers.vault-api.tls.passthrough=true",
    // "traefik.tcp.services.vault-api.loadbalancer.server.scheme=http",
    // "traefik.http.services.vault-api.loadbalancer.server.port=9000"
  ]
}

services {
  id      = "vault-external"
  name    = "vault"
}
