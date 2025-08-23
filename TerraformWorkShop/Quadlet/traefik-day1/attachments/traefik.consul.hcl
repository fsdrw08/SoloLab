services {
  name = "traefik-day1"
  id   = "traefik-ping"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id       = "traefik-http-check-8080"
      name     = "traefik-http-check-8080"
      http     = "http://traefik.day1.sololab:8080/ping"
      interval = "300s"
      timeout  = "2s"
      status   = "passing"
    }
  ]

  tags = [
    "exporter",

    # "traefik.enable=true",
    # "traefik.http.routers.dashboard-redirect.entrypoints=web",
    # "traefik.http.routers.dashboard-redirect.rule=Host(`traefik.day1.sololab`)&&(PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    # "traefik.http.routers.dashboard-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.dashboard-redirect.service=api@internal",
    # "traefik.http.routers.dashboard.entryPoints=webSecure",
    # "traefik.http.routers.dashboard.tls=true",
    # "traefik.http.routers.dashboard.rule=Host(`traefik.day1.sololab`)&&(PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    # "traefik.http.routers.dashboard.service=api@internal",
    # "traefik.http.routers.dashboard.middlewares=userPass@file",
    # "traefik.http.routers.metrics.entryPoints=webSecure",
    # "traefik.http.routers.metrics.tls=true",
    # "traefik.http.routers.metrics.rule=Host(`traefik.day1.sololab`)&&PathPrefix(`/metrics`)",
    # "traefik.http.routers.metrics.service=prometheus@internal",
  ]
  meta = {
    scheme            = "https"
    address           = "traefik.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}
