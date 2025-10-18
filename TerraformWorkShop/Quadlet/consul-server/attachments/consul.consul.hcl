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
    "exporter-consul",

    "traefik.enable=true",
    "traefik.http.routers.consul-redirect.entrypoints=web",
    "traefik.http.routers.consul-redirect.rule=Host(`consul.day1.sololab`) || Host(`consul.service.consul`)",
    "traefik.http.routers.consul-redirect.middlewares=toHttps@file",
    "traefik.http.routers.consul.entrypoints=webSecure",
    "traefik.http.routers.consul.rule=Host(`consul.day1.sololab`) || Host(`consul.service.consul`)",
    "traefik.http.routers.consul.tls=true",
    "traefik.http.services.consul.loadBalancer.serversTransport=consul-day1@file",
    "traefik.http.services.consul.loadbalancer.server.scheme=https",
  ]

  meta = {
    scheme            = "https"
    address           = "consul.service.consul"
    health_check_path = "v1/status/leader"
    # https://developer.hashicorp.com/consul/docs/reference/agent/configuration-file/telemetry#telemetry-prometheus_retention_time
    metrics_path              = "v1/agent/metrics"
    metrics_path_param_format = "prometheus"
  }
}