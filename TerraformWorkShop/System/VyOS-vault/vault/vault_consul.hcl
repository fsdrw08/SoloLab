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
    "traefik.http.routers.vault-api-redirect.rule=Host(`vault.service.consul`)",
    "traefik.http.routers.vault-api-redirect.entrypoints=web",
    "traefik.http.routers.vault-api-redirect.middlewares=toHttps@file",
    "traefik.http.routers.vault-api.rule=Host(`vault.service.consul`)",
    "traefik.http.routers.vault-api.entrypoints=websecure",
    "traefik.http.services.vault-api.loadbalancer.server.scheme=http",
    // "traefik.http.services.vault-api.loadbalancer.server.port=9000"
  ]
}

services {
  id      = "vault-internal-console"
  name    = "vault"
  address = "127.0.0.1"
  port    = 9001

  checks = [
    {
      id       = "vault-console-tcp-check-9001"
      name     = "vault-console-tcp-check-9001"
      tcp      = "127.0.0.1:9001"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.vault-console-redirect.rule=Host(`vault.service.consul`) && PathPrefix(`/ui`)",
    "traefik.http.routers.vault-console-redirect.entrypoints=web",
    "traefik.http.routers.vault-console-redirect.middlewares=toHttps@file",
    // "traefik.http.routers.vault-console-redirect.middlewares=vault-console-stripprefix@consulcatalog",
    "traefik.http.routers.vault-console.rule=Host(`vault.service.consul`) && PathPrefix(`/ui`)",
    "traefik.http.routers.vault-console.entrypoints=websecure",
    "traefik.http.routers.vault-console.middlewares=vault-console-stripprefix@consulcatalog",
    "traefik.http.routers.vault-console.tls.certresolver=internal",
    "traefik.http.middlewares.vault-console-stripprefix.stripPrefix.prefixes=/ui",
    "traefik.http.middlewares.vault-console-stripprefix.stripPrefix.forceSlash=false",
    "traefik.http.services.vault-console.loadbalancer.server.scheme=http",
    // "traefik.http.services.vault-console.loadbalancer.server.port=9001"
  ]
}

services {
  id      = "vault-external"
  name    = "vault"
}
