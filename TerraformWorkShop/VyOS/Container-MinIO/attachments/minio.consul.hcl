# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "minio-vyos"
  id   = "minio-api"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-api-https-check"
      name            = "minio-api-https-check"
      http            = "https://localhost:9000/minio/health/live"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "exporter",

    # "traefik.enable=true",
    # "traefik.http.routers.minio-api-redirect.entrypoints=web",
    # "traefik.http.routers.minio-api-redirect.rule=Host(`minio-api.day1.sololab`)",
    # "traefik.http.routers.minio-api-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.minio-api.entrypoints=webSecure",
    # "traefik.http.routers.minio-api.rule=Host(`minio-api.day1.sololab`)",
    # "traefik.http.routers.minio-api.tls=true",
    # "traefik.http.services.minio-api.loadBalancer.serversTransport=minio-api@file",
    # "traefik.http.services.minio-api.loadbalancer.server.scheme=https",
  ]
  meta = {
    scheme            = "https"
    address           = "minio-api.vyos.sololab"
    health_check_path = "minio/health/live"
    metrics_path      = "minio/v2/metrics/cluster"
  }
}

services {
  name = "minio-vyos"
  id   = "minio-console"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-console-https-check"
      name            = "minio-console-https-check"
      http            = "https://localhost:9001/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    # "traefik-day1.enable=true",
    # "traefik-day1.http.routers.minio-console-redirect.entrypoints=web",
    # "traefik-day1.http.routers.minio-console-redirect.rule=Host(`minio-console.day1.sololab`)",
    # "traefik-day1.http.routers.minio-console-redirect.middlewares=toHttps@file",
    # "traefik-day1.http.routers.minio-console.entrypoints=webSecure",
    # "traefik-day1.http.routers.minio-console.rule=Host(`minio-console.day1.sololab`)",
    # "traefik-day1.http.routers.minio-console.tls=true",
    # "traefik-day1.http.services.minio-console.loadBalancer.serversTransport=minio-console@file",
    # "traefik-day1.http.services.minio-console.loadbalancer.server.scheme=https",
  ]
}