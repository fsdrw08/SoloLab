# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "prometheus-podman-exporter" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "prometheus-podman-exporter" {

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "prometheus-podman-exporter" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "prometheus-podman-exporter-${attr.unique.hostname}"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          port           = 9882
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
          "traefik.http.routers.prometheus-podman-exporter-${attr.unique.hostname}-redirect.entryPoints=web",
          "traefik.http.routers.prometheus-podman-exporter-${attr.unique.hostname}-redirect.rule=(Host(`prometheus-podman-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-podman-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-podman-exporter-${attr.unique.hostname}-redirect.middlewares=toHttps@file",

          "traefik.http.routers.prometheus-podman-exporter-${attr.unique.hostname}.entryPoints=webSecure",
          "traefik.http.routers.prometheus-podman-exporter-${attr.unique.hostname}.rule=(Host(`prometheus-podman-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-podman-exporter-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.prometheus-podman-exporter-${attr.unique.hostname}.tls=true",

          "traefik.http.services.prometheus-podman-exporter-${attr.unique.hostname}.loadbalancer.server.scheme=https",
          "traefik.http.services.prometheus-podman-exporter-${attr.unique.hostname}.loadbalancer.server.port=443",
          "traefik.http.services.prometheus-podman-exporter-${attr.unique.hostname}.loadBalancer.serversTransport=consul-service@file",
        ]
        meta {
          scheme            = "https"
          address           = "prometheus-podman-exporter-${attr.unique.hostname}.service.consul"
          health_check_path = "metrics"
          metrics_path      = "metrics"
        }
      }

      driver = "podman"

      user = "root"
      config {
        image = "zot.day0.sololab/navidys/prometheus-podman-exporter:v1.20.0"
        args = [
          "--web.listen-address=:9882",
        ]
        labels = {
          "traefik.enable"                                                                               = "true"
          "traefik.http.routers.prometheus-podman-exporter-${attr.unique.hostname}-redirect.entrypoints" = "web"
          "traefik.http.routers.prometheus-podman-exporter-redirect.rule"                                = "(Host(`prometheus-podman-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-podman-exporter-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.prometheus-podman-exporter-redirect.middlewares"                         = "toHttps@file"
          "traefik.http.routers.prometheus-podman-exporter.service"                                      = "prometheus-podman-exporter"

          "traefik.http.routers.prometheus-podman-exporter.entrypoints" = "webSecure"
          "traefik.http.routers.prometheus-podman-exporter.rule"        = "(Host(`prometheus-podman-exporter.${attr.unique.hostname}.sololab`)||Host(`prometheus-podman-exporter-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.prometheus-podman-exporter.tls"         = "true"
          "traefik.http.routers.prometheus-podman-exporter.service"     = "prometheus-podman-exporter"

          "traefik.http.services.prometheus-podman-exporter.loadbalancer.server.port" = "9882"
        }
        hostname = "${attr.unique.hostname}"
        security_opt = [
          "label=type:spc_t",
        ]

        volumes = ["/run/podman/podman.sock:/run/podman/podman.sock"]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ             = "Asia/Shanghai"
        CONTAINER_HOST = "unix:///run/podman/podman.sock"
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