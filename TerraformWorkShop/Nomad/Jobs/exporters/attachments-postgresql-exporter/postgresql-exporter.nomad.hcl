# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "prometheus-postgresql-exporter" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "=="
    value     = "day2"
  }

  group "prometheus-postgresql-exporter" {

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "prometheus-postgresql-exporter" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "prometheus-postgresql-exporter"
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

        meta {
          scheme            = "https"
          address           = "prometheus-postgresql-exporter.service.consul"
          health_check_path = "metrics"
          metrics_path      = "metrics"
        }

        tags = [
          "exporter",

          "traefik.enable=true",
          "traefik.http.routers.prometheus-postgresql-exporter-redirect.entryPoints=web",
          "traefik.http.routers.prometheus-postgresql-exporter-redirect.rule=(Host(`prometheus-postgresql-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgresql-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-postgresql-exporter-redirect.middlewares=toHttps@file",

          "traefik.http.routers.prometheus-postgresql-exporter.entryPoints=webSecure",
          "traefik.http.routers.prometheus-postgresql-exporter.rule=(Host(`prometheus-postgresql-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgresql-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-postgresql-exporter.tls=true",

          "traefik.http.services.prometheus-postgresql-exporter.loadbalancer.server.scheme=https",
          "traefik.http.services.prometheus-postgresql-exporter.loadbalancer.server.port=443",
          "traefik.http.services.prometheus-postgresql-exporter.loadBalancer.serversTransport=consul-service@file",
        ]
      }

      driver = "podman"

      user = "root"
      config {
        image = "zot.day0.sololab/prometheuscommunity/postgres-exporter:v0.18.1"
        labels = {
          "traefik.enable"                                                                                   = "true"
          "traefik.http.routers.prometheus-postgresql-exporter-${attr.unique.hostname}-redirect.entrypoints" = "web"
          "traefik.http.routers.prometheus-postgresql-exporter-redirect.rule"                                = "(Host(`prometheus-postgresql-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgresql-exporter.service.consul`))"
          "traefik.http.routers.prometheus-postgresql-exporter-redirect.middlewares"                         = "toHttps@file"
          "traefik.http.routers.prometheus-postgresql-exporter.service"                                      = "prometheus-postgresql-exporter"

          "traefik.http.routers.prometheus-postgresql-exporter.entrypoints" = "webSecure"
          "traefik.http.routers.prometheus-postgresql-exporter.rule"        = "(Host(`prometheus-postgresql-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-postgresql-exporter.service.consul`))"
          "traefik.http.routers.prometheus-postgresql-exporter.tls"         = "true"
          "traefik.http.routers.prometheus-postgresql-exporter.service"     = "prometheus-postgresql-exporter"

          "traefik.http.services.prometheus-postgresql-exporter.loadbalancer.server.port" = "9187"
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
        memory = 128
      }

    }
  }
}