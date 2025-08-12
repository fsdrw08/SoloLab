services {
  id   = "grafana"
  name = "grafana"
  port = 9000

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "grafana-https-check"
      name            = "grafana-https-check"
      http            = "https://grafana.day1.sololab/api/health"
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