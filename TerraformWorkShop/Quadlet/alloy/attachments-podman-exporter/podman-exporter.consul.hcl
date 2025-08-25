services {
  name = "prometheus-podman-exporter-day1"
  id   = "prometheus-podman-exporter-workload"
  port = 9882

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-podman-exporter-http-check"
      name            = "prometheus-podman-exporter-http-check"
      http            = "http://localhost:9882/"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "exporter",

    "traefik-day1.enable=true",
    "traefik-day1.http.routers.podman-exporter-redirect.entrypoints=web",
    "traefik-day1.http.routers.podman-exporter-redirect.rule=Host(`prometheus-podman-exporter.day1.sololab`)",
    "traefik-day1.http.routers.podman-exporter-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.podman-exporter.entrypoints=webSecure",
    "traefik-day1.http.routers.podman-exporter.rule=Host(`prometheus-podman-exporter.day1.sololab`)",
    "traefik-day1.http.routers.podman-exporter.tls=true",
    "traefik-day1.http.services.podman-exporter.loadbalancer.server.port=9882",
  ]
  meta = {
    scheme            = "http"
    address           = "prometheus-podman-exporter.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}