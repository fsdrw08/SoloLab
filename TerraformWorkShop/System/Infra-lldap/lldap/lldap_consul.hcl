// https://developer.hashicorp.com/lldap/docs/services/configuration/services-configuration-reference
services {
  id      = "lldap-internal-http"
  name    = "lldap-internal"
  address = "127.0.0.1"
  port    = 17170

  checks = [
    {
      id       = "lldap-tcp-check-17170"
      name     = "lldap-tcp-check-17170"
      tcp      = "127.0.0.1:17170"
      interval = "20s"
      timeout  = "2s"
    }
  ]

   tags = [
    "traefik.enable=true",
    "traefik.http.routers.lldap-http.entrypoints=web",
    "traefik.http.routers.lldap-http.rule=Host(`lldap.service.lldap`)",
    "traefik.http.routers.lldap-http.middlewares=toHttps@file",
    "traefik.http.routers.lldap-https.rule=Host(`lldap.service.consul`)",
    "traefik.http.routers.lldap-https.entrypoints=websecure",
    "traefik.http.routers.lldap-https.tls=true",
    "traefik.http.services.lldap-https.loadbalancer.server.scheme=http",
  ]
}

services {
  id      = "lldap-external"
  name    = "lldap"
}
