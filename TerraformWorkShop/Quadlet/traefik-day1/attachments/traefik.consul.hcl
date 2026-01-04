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
    "metrics-exposing-blackbox",
    "metrics-exposing-general",

    "traefik.enable=true",
    "traefik.http.routers.trafik-dashboard-redirect.entryPoints=web",
    "traefik.http.routers.trafik-dashboard-redirect.rule=(Host(`traefik.day1.sololab`)||Host(`traefik-day1.service.consul`)) && (PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    "traefik.http.routers.trafik-dashboard-redirect.middlewares=toHttps@file",
    "traefik.http.routers.trafik-dashboard-redirect.service=api@internal",
    "traefik.http.routers.trafik-dashboard.entryPoints=webSecure",
    "traefik.http.routers.trafik-dashboard.tls=true",
    "traefik.http.routers.trafik-dashboard.rule=(Host(`traefik.day1.sololab`)||Host(`traefik-day1.service.consul`)) && (PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    "traefik.http.routers.trafik-dashboard.service=api@internal",
    "traefik.http.routers.trafik-dashboard.middlewares=userPass@file",
    "traefik.http.routers.metrics.entryPoints=webSecure",
    "traefik.http.routers.metrics.rule=(Host(`traefik.day1.sololab`)||Host(`traefik-day1.service.consul`)) && PathPrefix(`/metrics`)",
    "traefik.http.routers.metrics.tls=true",
    "traefik.http.routers.metrics.service=prometheus@internal",
  ]
  meta = {
    scheme            = "https"
    address           = "traefik-day1.service.consul"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}
