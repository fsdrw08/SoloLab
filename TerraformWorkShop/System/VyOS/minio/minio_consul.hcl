services {
  id      = "minio-internal-api"
  name    = "minio-internal-api"
  address = "127.0.0.1"
  port    = 9000

  checks = [
    {
      id       = "minio-api-tcp-check-9000"
      name     = "minio-api-tcp-check-9000"
      tcp      = "127.0.0.1:9000"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.minio-api-redirect.rule=Host(`minio.service.consul`)",
    "traefik.http.routers.minio-api-redirect.entrypoints=web",
    "traefik.http.routers.minio-api-redirect.middlewares=toHttps@file",
    "traefik.http.routers.minio-api.rule=Host(`minio.service.consul`)",
    "traefik.http.routers.minio-api.entrypoints=websecure",
    "traefik.http.routers.minio-api.tls.certresolver=internal",
    "traefik.http.services.minio-api.loadbalancer.server.scheme=http",
    // "traefik.http.services.minio-api.loadbalancer.server.port=9000"
  ]
}

services {
  id      = "minio-internal-console"
  name    = "minio-internal-console"
  address = "127.0.0.1"
  port    = 9001

  checks = [
    {
      id       = "minio-console-tcp-check-9001"
      name     = "minio-console-tcp-check-9001"
      tcp      = "127.0.0.1:9001"
      interval = "20s"
      timeout  = "2s"
    }
  ]

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.minio-console-redirect.rule=Host(`minio.service.consul`) && PathPrefix(`/ui`)",
    "traefik.http.routers.minio-console-redirect.entrypoints=web",
    "traefik.http.routers.minio-console-redirect.middlewares=toHttps@file",
    // "traefik.http.routers.minio-console-redirect.middlewares=minio-console-stripprefix@consulcatalog",
    "traefik.http.routers.minio-console.rule=Host(`minio.service.consul`) && PathPrefix(`/ui`)",
    "traefik.http.routers.minio-console.entrypoints=websecure",
    "traefik.http.routers.minio-console.middlewares=minio-console-stripprefix@consulcatalog",
    "traefik.http.routers.minio-console.tls.certresolver=internal",
    "traefik.http.middlewares.minio-console-stripprefix.stripPrefix.prefixes=/ui",
    "traefik.http.middlewares.minio-console-stripprefix.stripPrefix.forceSlash=false",
    "traefik.http.services.minio-console.loadbalancer.server.scheme=http",
    // "traefik.http.services.minio-console.loadbalancer.server.port=9001"
  ]
}

services {
  id      = "minio"
  name    = "minio"
  address = "192.168.255.2"
}
