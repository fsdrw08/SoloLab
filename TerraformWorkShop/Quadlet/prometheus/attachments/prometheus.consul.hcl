# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "prometheus-day1"
  id   = "prometheus"
  port = 9090

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-https-check"
      name            = "prometheus-https-check"
      http            = "https://prometheus.day1.sololab/-/healthy"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "exporter",

    # "traefik.enable=true",
    # "traefik.http.routers.prometheus-redirect.entrypoints=web",
    # "traefik.http.routers.prometheus-redirect.rule=Host(`prometheus.day1.sololab`)",
    # "traefik.http.routers.prometheus-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.prometheus.entryPoints=webSecure",
    # "traefik.http.routers.prometheus.rule=Host(`prometheus.day1.sololab`)",
    # "traefik.http.routers.prometheus.tls=true",
    # "traefik.http.services.prometheus.loadBalancer.serversTransport=prometheus@file",
    # "traefik.http.services.prometheus.loadbalancer.server.scheme=https",
  ]
  meta = {
    scheme            = "https"
    address           = "prometheus.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}

services {
  id   = "prometheus-blackbox-exporter"
  name = "prometheus-blackbox-exporter"
  port = 9115

  checks = [
    {
      # https://developer.hashicorp.com/consul/docs/services/usage/checks#http-checks
      id              = "prometheus-blackbox-exporter-https-check"
      name            = "prometheus-blackbox-exporter-https-check"
      http            = "https://prometheus-blackbox-exporter.day1.sololab/-/healthy"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "exporter",

    # "traefik.enable=true",
    # "traefik.http.routers.prometheus-blackbox-exporter-redirect.entrypoints=web",
    # "traefik.http.routers.prometheus-blackbox-exporter-redirect.rule=Host(`prometheus-blackbox-exporter.day1.sololab`)",
    # "traefik.http.routers.prometheus-blackbox-exporter-redirect.middlewares=toHttps@file",
    # "traefik.http.routers.prometheus-blackbox-exporter.entryPoints=webSecure",
    # "traefik.http.routers.prometheus-blackbox-exporter.rule=Host(`prometheus-blackbox-exporter.day1.sololab`)",
    # "traefik.http.routers.prometheus-blackbox-exporter.tls=true",
  ]
  meta = {
    scheme            = "http"
    address           = "prometheus-blackbox-exporter.day1.sololab"
    health_check_path = "metrics"
    metrics_path      = "metrics"
  }
}