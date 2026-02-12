# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "minio"
  id   = "minio-api"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-api-https-check"
      name            = "minio-api-https-check"
      http            = "http://localhost:9000/minio/health/live"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-general",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "minio-api.day0.sololab"
    prom_blackbox_health_check_path = "minio/health/live"

    prom_target_scheme       = "https"
    prom_target_address      = "minio-api.day0.sololab"
    prom_target_metrics_path = "minio/v2/metrics/cluster"
  }
}

services {
  name = "minio"
  id   = "minio-console"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-console-https-check"
      name            = "minio-console-https-check"
      http            = "http://localhost:9001/"
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