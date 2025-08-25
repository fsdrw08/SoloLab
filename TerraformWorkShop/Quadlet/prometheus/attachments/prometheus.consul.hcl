# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "prometheus-day1"
  id   = "prometheus-server"
  port = 9090

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-https-check"
      name            = "prometheus-https-check"
      http            = "https://localhost:9090/-/healthy"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "exporter",

    "traefik-day1.enable=true",
    "traefik-day1.http.routers.prometheus-redirect.entrypoints=web",
    "traefik-day1.http.routers.prometheus-redirect.rule=Host(`prometheus.day1.sololab`)",
    "traefik-day1.http.routers.prometheus-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.prometheus.entryPoints=webSecure",
    "traefik-day1.http.routers.prometheus.rule=Host(`prometheus.day1.sololab`)",
    "traefik-day1.http.routers.prometheus.tls=true",
    "traefik-day1.http.services.prometheus.loadBalancer.serversTransport=prometheus@file",
    "traefik-day1.http.services.prometheus.loadbalancer.server.scheme=https",
  ]
  meta = {
    scheme            = "https"
    address           = "prometheus.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}

services {
  name = "prometheus-blackbox-exporter-day1"
  id   = "prometheus-blackbox-exporter"
  port = 9115

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-blackbox-exporter-https-check"
      name            = "prometheus-blackbox-exporter-https-check"
      http            = "http://localhost:9115/-/healthy"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "exporter",

    "traefik-day1.enable=true",
    "traefik-day1.http.routers.prometheus-blackbox-exporter-redirect.entrypoints=web",
    "traefik-day1.http.routers.prometheus-blackbox-exporter-redirect.rule=Host(`prometheus-blackbox-exporter.day1.sololab`)",
    "traefik-day1.http.routers.prometheus-blackbox-exporter-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.prometheus-blackbox-exporter.entryPoints=webSecure",
    "traefik-day1.http.routers.prometheus-blackbox-exporter.rule=Host(`prometheus-blackbox-exporter.day1.sololab`)",
    "traefik-day1.http.routers.prometheus-blackbox-exporter.tls=true",
  ]
  meta = {
    scheme            = "http"
    address           = "prometheus-blackbox-exporter.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}