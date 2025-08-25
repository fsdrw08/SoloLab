# https://developer.hashicorp.com/consul/docs/reference/service
services {
  name = "consul-day1"
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
    "consul-exporter",

    "traefik-day1.enable=true",
    "traefik-day1.http.routers.consul-redirect.entrypoints=web",
    "traefik-day1.http.routers.consul-redirect.rule=Host(`consul.day1.sololab`)",
    "traefik-day1.http.routers.consul-redirect.middlewares=toHttps@file",
    "traefik-day1.http.routers.consul.entrypoints=webSecure",
    "traefik-day1.http.routers.consul.rule=Host(`consul.day1.sololab`)",
    "traefik-day1.http.routers.consul.tls=true",
    "traefik-day1.http.services.consul.loadBalancer.serversTransport=consul@file",
    "traefik-day1.http.services.consul.loadbalancer.server.scheme=https",
  ]

  meta = {
    scheme            = "https"
    address           = "consul.day1.sololab"
    health_check_path = "v1/status/leader"
    # https://developer.hashicorp.com/consul/docs/reference/agent/configuration-file/telemetry#telemetry-prometheus_retention_time
    metrics_path              = "v1/agent/metrics"
    metrics_path_param_format = "prometheus"
  }
}