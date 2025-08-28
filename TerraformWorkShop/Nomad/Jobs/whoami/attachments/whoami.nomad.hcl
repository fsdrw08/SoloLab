# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-whoami
job "whoami" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  group "whoami" {
    network {
      port "http" {
        static = 8080
      }
    }

    service {
      provider = "consul"
      name     = "whoami-${attr.unique.hostname}"
      port     = "webSecure"

      check {
        type     = "http"
        path     = "/ping"
        port     = "whoami"
        interval = "10s"
        timeout  = "2s"
      }

      meta {
        scheme            = "https"
        address           = "whoami-${attr.unique.hostname}.service.consul"
        health_check_path = "metrics"
        metrics_path      = "metrics"
      }

      tags = [
        "exporter",
      ]

    }

    volume "certs" {
      type   = "host"
      source = "whoami"
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "whoami" {
      driver = "docker"

      config {
        image = "zot.day0.sololab/traefik/whoami:v1.10"
        labels = {
          "whoami.enable"                                      = "true"
          "whoami.http.routers.dashboard-redirect.entrypoints" = "web"
          "whoami.http.routers.dashboard-redirect.rule"        = "(Host(`whoami.${attr.unique.hostname}.sololab`) || Host(`whoami-${attr.unique.hostname}.service.consul`)) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "whoami.http.routers.dashboard-redirect.middlewares" = "toHttps@file"
          "whoami.http.routers.dashboard-redirect.service"     = "api@internal"

          "whoami.http.routers.dashboard.entryPoints"      = "webSecure"
          "whoami.http.routers.dashboard.tls.certresolver" = "internal"
          "whoami.http.routers.dashboard.rule"             = "(Host(`whoami.${attr.unique.hostname}.sololab`) || Host(`whoami-${attr.unique.hostname}.service.consul`)) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "whoami.http.routers.dashboard.service"          = "api@internal"
          "whoami.http.routers.dashboard.middlewares"      = "userPass@file"
          # https://community.whoami.io/t/api-not-accessible-when-whoami-in-host-network-mode/13321/2,
          "whoami.http.services.dashboard.loadbalancer.server.port" = "443"

          "whoami.http.routers.metrics.entryPoints" = "webSecure"
          "whoami.http.routers.metrics.tls"         = "true"
          "whoami.http.routers.metrics.rule"        = "(Host(`whoami.${attr.unique.hostname}.sololab`) || Host(`whoami-${attr.unique.hostname}.service.consul`)) && PathPrefix(`/metrics`)"
          "whoami.http.routers.metrics.service"     = "prometheus@internal"
        }
        network_mode = "host"
        # ports        = ["web", "webSecure", "whoami"]

        security_opt = [
          "label=type:spc_t",
        ]

      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
      }
    }
  }
}