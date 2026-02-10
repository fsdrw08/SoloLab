variable "postgresql_exporter_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "prometheus-postgres-exporter" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "=="
    value     = "day2"
  }

  group "prometheus-postgres-exporter" {

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "prometheus-postgres-exporter" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "prometheus-postgres-exporter"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          port           = 9187
          type           = "http"
          path           = "/"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "log",

          "traefik.enable=true",
          "traefik.http.routers.prometheus-postgres-exporter-redirect.entryPoints=web",
          "traefik.http.routers.prometheus-postgres-exporter-redirect.rule=(Host(`prometheus-postgres-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgres-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-postgres-exporter-redirect.middlewares=toHttps@file",

          "traefik.http.routers.prometheus-postgres-exporter.entryPoints=webSecure",
          "traefik.http.routers.prometheus-postgres-exporter.rule=(Host(`prometheus-postgres-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgres-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-postgres-exporter.tls=true",

          "traefik.http.services.prometheus-postgres-exporter.loadbalancer.server.scheme=https",
          "traefik.http.services.prometheus-postgres-exporter.loadbalancer.server.port=443",
          "traefik.http.services.prometheus-postgres-exporter.loadBalancer.serversTransport=consul-service@file",
        ]
      }

      driver = "podman"

      user = "root"
      config {
        image = "zot.day0.sololab/prometheuscommunity/postgres-exporter:v0.18.1"
        labels = {
          "traefik.enable"                                                                                 = "true"
          "traefik.http.routers.prometheus-postgres-exporter-${attr.unique.hostname}-redirect.entrypoints" = "web"
          "traefik.http.routers.prometheus-postgres-exporter-redirect.rule"                                = "(Host(`prometheus-postgres-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgres-exporter.service.consul`))"
          "traefik.http.routers.prometheus-postgres-exporter-redirect.middlewares"                         = "toHttps@file"
          "traefik.http.routers.prometheus-postgres-exporter.service"                                      = "prometheus-postgres-exporter"

          "traefik.http.routers.prometheus-postgres-exporter.entrypoints" = "webSecure"
          "traefik.http.routers.prometheus-postgres-exporter.rule"        = "(Host(`prometheus-postgres-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgres-exporter.service.consul`))"
          "traefik.http.routers.prometheus-postgres-exporter.tls"         = "true"
          "traefik.http.routers.prometheus-postgres-exporter.service"     = "prometheus-postgres-exporter"

          "traefik.http.services.prometheus-postgres-exporter.loadbalancer.server.port" = "9187"
        }
        hostname = "${attr.unique.hostname}"
        args = [
          "--config.file=/secrets/postgres_exporter.yaml",
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
      }

      template {
        data        = var.postgresql_exporter_config
        destination = "secrets/postgres_exporter.yaml"
        change_mode = "restart"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 64
      }

      vault {}

    }
  }
}