# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "prometheus-node-exporter" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "prometheus-node-exporter" {

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "prometheus-node-exporter" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "prometheus-node-exporter-${attr.unique.hostname}"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          port           = 9100
          type           = "http"
          path           = "/"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "log",
          "metrics-exposing-general",

          "traefik.enable=true",
          "traefik.http.routers.prometheus-node-exporter-${attr.unique.hostname}-redirect.entryPoints=web",
          "traefik.http.routers.prometheus-node-exporter-${attr.unique.hostname}-redirect.rule=(Host(`prometheus-node-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-node-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-node-exporter-${attr.unique.hostname}-redirect.middlewares=toHttps@file",

          "traefik.http.routers.prometheus-node-exporter-${attr.unique.hostname}.entryPoints=webSecure",
          "traefik.http.routers.prometheus-node-exporter-${attr.unique.hostname}.rule=(Host(`prometheus-node-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-node-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-node-exporter-${attr.unique.hostname}.tls=true",

          "traefik.http.services.prometheus-node-exporter-${attr.unique.hostname}.loadbalancer.server.scheme=https",
          "traefik.http.services.prometheus-node-exporter-${attr.unique.hostname}.loadbalancer.server.port=443",
          "traefik.http.services.prometheus-node-exporter-${attr.unique.hostname}.loadBalancer.serversTransport=consul-service@file",
        ]
        meta {
          exporter_scheme       = "https"
          exporter_address      = "prometheus-node-exporter-${attr.unique.hostname}.service.consul"
          exporter_metrics_path = "metrics"
        }
      }

      driver = "podman"

      config {
        image = "zot.day0.sololab/prometheus/node-exporter:v1.10.2"
        args = [
          "--path.rootfs=/host",
          "--web.listen-address=:9100",
        ]
        labels = {
          "traefik.enable"                                                     = "true"
          "traefik.http.routers.prometheus-node-exporter-redirect.entrypoints" = "web"
          "traefik.http.routers.prometheus-node-exporter-redirect.rule"        = "(Host(`prometheus-node-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-node-exporter-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.prometheus-node-exporter-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.prometheus-node-exporter.service"              = "prometheus-node-exporter"

          "traefik.http.routers.prometheus-node-exporter.entrypoints" = "webSecure"
          "traefik.http.routers.prometheus-node-exporter.rule"        = "(Host(`prometheus-node-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-node-exporter-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.prometheus-node-exporter.tls"         = "true"
          "traefik.http.routers.prometheus-node-exporter.service"     = "prometheus-node-exporter"

          "traefik.http.services.prometheus-node-exporter.loadbalancer.server.port" = "9100"
        }
        hostname = "${attr.unique.hostname}"

        volumes = ["/:/host:ro,rslave"]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 32
      }

    }
  }
}