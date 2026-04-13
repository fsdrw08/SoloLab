services {
  name = "traefik"
  id   = "traefik-day1"
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
    "day1",
    "metrics-exposing-blackbox",
    "metrics-exposing-general",

    "traefik.enable=true",
    "traefik.http.routers.trafik-dashboard-redirect.entryPoints=web",
    "traefik.http.routers.trafik-dashboard-redirect.rule=(Host(`traefik.day1.sololab`)||Host(`day1.traefik.service.consul`)) && (PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    "traefik.http.routers.trafik-dashboard-redirect.middlewares=toHttps@file",
    "traefik.http.routers.trafik-dashboard-redirect.service=api@internal",
    "traefik.http.routers.trafik-dashboard.entryPoints=webSecure",
    "traefik.http.routers.trafik-dashboard.tls=true",
    "traefik.http.routers.trafik-dashboard.rule=(Host(`traefik.day1.sololab`)||Host(`day1.traefik.service.consul`)) && (PathPrefix(`/api`)||PathPrefix(`/dashboard`))",
    "traefik.http.routers.trafik-dashboard.service=api@internal",
    "traefik.http.routers.trafik-dashboard.middlewares=userPass@file",
    "traefik.http.routers.metrics.entryPoints=webSecure",
    "traefik.http.routers.metrics.rule=(Host(`traefik.day1.sololab`)||Host(`day1.traefik.service.consul`)) && PathPrefix(`/metrics`)",
    "traefik.http.routers.metrics.tls=true",
    "traefik.http.routers.metrics.service=prometheus@internal",
  ]
  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "day1.traefik.service.consul"
    prom_blackbox_health_check_path = "metrics"

    prom_target_scheme       = "https"
    prom_target_address      = "day1.traefik.service.consul"
    prom_target_metrics_path = "metrics"
  }
}
