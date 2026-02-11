# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "prometheus-redis-exporter" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "prometheus-redis-exporter" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "prometheus-redis-exporter" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "prometheus-redis-exporter"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          port           = 9121
          type           = "http"
          path           = "/"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "log",
        ]
      }

      driver = "podman"
      config {
        image = "zot.day0.sololab/oliver006/redis_exporter:v1.80.2-alpine"
        labels = {
          "traefik.enable"                                                      = "true"
          "traefik.http.routers.prometheus-redis-exporter-redirect.entrypoints" = "web"
          "traefik.http.routers.prometheus-redis-exporter-redirect.rule"        = "Host(`prometheus-redis-exporter.service.consul`)"
          "traefik.http.routers.prometheus-redis-exporter-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.prometheus-redis-exporter.service"              = "prometheus-redis-exporter"

          "traefik.http.routers.prometheus-redis-exporter.entrypoints" = "webSecure"
          "traefik.http.routers.prometheus-redis-exporter.rule"        = "Host(`prometheus-redis-exporter.service.consul`)"
          "traefik.http.routers.prometheus-redis-exporter.tls"         = "true"
          "traefik.http.routers.prometheus-redis-exporter.service"     = "prometheus-redis-exporter"

          "traefik.http.services.prometheus-redis-exporter.loadbalancer.server.port" = "9121"
        }
        hostname = "${attr.unique.hostname}"

      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ             = "Asia/Shanghai"
        REDIS_ADDR     = "redis://redis-${attr.unique.hostname}.service.consul:6379"
        REDIS_USER     = "exporter"
        REDIS_PASSWORD = "exporter"

      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 64
      }

    }
  }
}