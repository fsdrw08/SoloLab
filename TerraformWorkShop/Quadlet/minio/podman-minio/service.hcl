services {
  id   = "minio-api"
  name = "minio"
  port = 9000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "minio-api-https-check"
      name            = "minio-api-https-check"
      http            = "https://minio-api.day1.sololab/minio/health/live"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
    }
  ]

  # tags = [
  #   "traefik.enable=true",
  #   "traefik.tcp.routers.minio-console-web.entrypoints=webSecure",
  #   "traefik.tcp.routers.minio-console-web.rule=HostSNI(`minio-console.day1.sololab`)",
  #   "traefik.tcp.routers.minio-console-web.tls.passthrough=true",
  #   # "traefik.http.routers.minio-console-web-redirect.entrypoints=web",
  #   # "traefik.http.routers.minio-console-web-redirect.rule=Host(`minio-console.day1.sololab`)",
  #   # "traefik.http.routers.minio-console-web-redirect.middlewares=toHttps@file",
  #   # "traefik.http.routers.minio-console-web.entrypoints=websecure",
  #   # "traefik.http.routers.minio-console-web.rule=Host(`minio-console.day1.sololab`)",
  #   # "traefik.http.routers.minio-console-web.tls=true",
  #   # "traefik.http.services.minio-console-web.loadbalancer.server.scheme=https",
  # ]
}