# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "consul"
  id   = "consul-agent"
  port = 8501

  checks = [
    {
      id              = "consul-https-check"
      name            = "consul-https-check"
      http            = "https://localhost:8501/v1/status/leader"
      tls_skip_verify = true
      interval        = "300s"
      timeout         = "2s"
      status          = "passing"
    }
  ]

  tags = [
    "metrics-exposing-blackbox",
    "metrics-exposing-consul",

    "traefik.enable=true",
    "traefik.http.routers.consul-redirect.entrypoints=web",
    "traefik.http.routers.consul-redirect.rule=Host(`consul.day1.sololab`) || Host(`consul.service.consul`)",
    "traefik.http.routers.consul-redirect.middlewares=toHttps@file",
    "traefik.http.routers.consul.entrypoints=webSecure",
    "traefik.http.routers.consul.rule=Host(`consul.day1.sololab`) || Host(`consul.service.consul`)",
    "traefik.http.routers.consul.tls=true",
    "traefik.http.services.consul.loadBalancer.serversTransport=sololab-day1@file",
    "traefik.http.services.consul.loadbalancer.server.scheme=https",
  ]

  meta = {
    prom_blackbox_scheme            = "https"
    prom_blackbox_address           = "consul.service.consul"
    prom_blackbox_health_check_path = "v1/status/leader"

    prom_target_scheme  = "https"
    prom_target_address = "consul.service.consul"
    # https://developer.hashicorp.com/consul/docs/reference/agent/configuration-file/telemetry#telemetry-prometheus_retention_time
    prom_target_metrics_path              = "v1/agent/metrics"
    prom_target_metrics_path_param_format = "prometheus"
  }
}