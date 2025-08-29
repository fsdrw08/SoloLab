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
        to = -1
      }
    }

    service {
      provider = "consul"
      name     = "whoami-${attr.unique.hostname}"
      # port     = 443
      port = "http"

      check {
        type = "http"
        path = "/"
        # port = 443
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }

    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "whoami" {
      driver = "docker"

      config {
        image = "zot.day0.sololab/traefik/whoami:v1.10"
        args = [
          # "--port=8081",
          "--port=${NOMAD_PORT_http}",
        ]
        labels = {
          "traefik.enable"                                   = "true"
          "traefik.http.routers.whoami-redirect.entrypoints" = "web"
          "traefik.http.routers.whoami-redirect.rule"        = "Host(`whoami.${attr.unique.hostname}.sololab`) || Host(`whoami-${attr.unique.hostname}.service.consul`)"
          "traefik.http.routers.whoami-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.whoami-redirect.service"     = "whoami"

          "traefik.http.routers.whoami.entryPoints"      = "webSecure"
          "traefik.http.routers.whoami.tls.certresolver" = "internal"
          "traefik.http.routers.whoami.rule"             = "Host(`whoami.${attr.unique.hostname}.sololab`) || Host(`whoami-${attr.unique.hostname}.service.consul`)"
          "traefik.http.routers.whoami.service"          = "whoami"
          # https://community.whoami.io/t/api-not-accessible-when-whoami-in-host-network-mode/13321/2,
          # "traefik.http.services.whoami.loadbalancer.server.port" = "8081"
          "traefik.http.services.whoami.loadbalancer.server.port" = "${NOMAD_PORT_http}"
        }
        network_mode = "host"
        # ports        = ["web", "webSecure", "whoami"]

      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
      }
    }
  }
}