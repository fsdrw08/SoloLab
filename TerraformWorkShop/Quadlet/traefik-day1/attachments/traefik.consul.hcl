services {
  name = "traefik-day1"
  id   = "traefik-proxy"
  port = 443

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id       = "traefik-http-check-8080"
      name     = "traefik-http-check-8080"
      http     = "http://localhost:8080/ping"
      interval = "300s"
      timeout  = "2s"
      status   = "passing"
    }
  ]

  tags = [
    "exporter",

    "traefik-day1.enable=true",
    "traefik-day1.http.routers.dashboard-redirect.entrypoints=web",
    "traefik-day1.http.routers.dashboard-redirect.rule=Host(`traefik.day1.sololab`)&&(PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    "traefik-day1.http.routers.dashboard-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.dashboard-redirect.service=api@internal",
    "traefik-day1.http.routers.dashboard.entryPoints=webSecure",
    "traefik-day1.http.routers.dashboard.tls=true",
    "traefik-day1.http.routers.dashboard.rule=Host(`traefik.day1.sololab`)&&(PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    "traefik-day1.http.routers.dashboard.service=api@internal",
    "traefik-day1.http.routers.dashboard.middlewares=userPass@file",
    "traefik-day1.http.routers.metrics.entryPoints=webSecure",
    "traefik-day1.http.routers.metrics.tls=true",
    "traefik-day1.http.routers.metrics.rule=Host(`traefik.day1.sololab`)&&PathPrefix(`/metrics`)",
    "traefik-day1.http.routers.metrics.service=prometheus@internal",
  ]
  meta = {
    scheme            = "https"
    address           = "traefik.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}
