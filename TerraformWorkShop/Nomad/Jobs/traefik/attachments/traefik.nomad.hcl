variable "install_config" {
  type = string
}

variable "routing_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-traefik
job "traefik" {
  datacenters = ["dc1"]
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "traefik" {
    network {
      port "web" {
        static = 80
      }
      port "webSecure" {
        static = 443
      }
      port "traefik" {
        static = 8080
      }
    }

    service {
      provider = "consul"
      name     = "traefik-${attr.unique.hostname}"
      port     = "webSecure"

      check {
        type     = "http"
        path     = "/ping"
        port     = "traefik"
        interval = "180s"
        timeout  = "2s"
      }

      meta {
        scheme            = "https"
        address           = "traefik-${attr.unique.hostname}.service.consul"
        health_check_path = "metrics"
        metrics_path      = "metrics"
      }

      tags = [
        "exporter",

        "traefik.enable=true",
        "traefik.http.routers.trafik-dashboard-redirect.entryPoints=web",
        "traefik.http.routers.trafik-dashboard-redirect.rule=Host(`traefik.${attr.unique.hostname}.sololab`)",
        "traefik.http.routers.trafik-dashboard-redirect.middlewares=toHttps@file",

        "traefik.http.routers.trafik-dashboard.entryPoints=webSecure",
        "traefik.http.routers.trafik-dashboard.rule=Host(`traefik.${attr.unique.hostname}.sololab`)",
        "traefik.http.routers.trafik-dashboard.tls.certresolver=internal",
        "traefik.http.services.trafik-dashboard.loadbalancer.server.scheme=https",
      ]

    }

    volume "certs" {
      type            = "csi"
      source          = "traefik-acme"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "traefik" {
      driver = "podman"

      config {
        image = "zot.day0.sololab/library/traefik:v3.5.3"
        labels = {
          "traefik.enable"                                      = "true"
          "traefik.http.routers.dashboard-redirect.entrypoints" = "web"
          "traefik.http.routers.dashboard-redirect.rule"        = "Host(`traefik.${attr.unique.hostname}.sololab`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "traefik.http.routers.dashboard-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.dashboard-redirect.service"     = "api@internal"

          "traefik.http.routers.dashboard.entryPoints"      = "webSecure"
          "traefik.http.routers.dashboard.tls.certresolver" = "internal"
          "traefik.http.routers.dashboard.rule"             = "Host(`traefik.${attr.unique.hostname}.sololab`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "traefik.http.routers.dashboard.service"          = "api@internal"
          "traefik.http.routers.dashboard.middlewares"      = "userPass@file"
          # https://community.traefik.io/t/api-not-accessible-when-traefik-in-host-network-mode/13321/2,
          "traefik.http.services.dashboard.loadbalancer.server.port" = "443"

          "traefik.http.routers.metrics.entryPoints" = "webSecure"
          "traefik.http.routers.metrics.tls"         = "true"
          "traefik.http.routers.metrics.rule"        = "Host(`traefik.${attr.unique.hostname}.sololab`) && PathPrefix(`/metrics`)"
          "traefik.http.routers.metrics.service"     = "prometheus@internal"
        }
        network_mode = "host"

        security_opt = [
          "label=type:spc_t",
        ]

        volumes = [
          "local/hosts:/etc/hosts",
          "local/install.traefik.yaml:/etc/traefik/traefik.yml",
          "local/routing.traefik.yaml:/etc/traefik/dynamic/routing.yml",
          "secrets/ca.crt:/etc/traefik/tls/ca.crt",
          "/run/podman/podman.sock:/var/run/docker.sock"
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
        # https://doc.traefik.io/traefik/https/acme/#casystemcertpool
        LEGO_CA_CERTIFICATES     = "/etc/traefik/tls/ca.crt"
        LEGO_CA_SYSTEM_CERT_POOL = "true"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/template
      template {
        data        = var.install_config
        destination = "local/install.traefik.yaml"
      }

      template {
        data        = var.routing_config
        destination = "local/routing.traefik.yaml"
      }

      template {
        data        = <<-EOF
        127.0.0.1       localhost localhost.localdomain
        ::1             localhost localhost.localdomain
        EOF
        destination = "local/hosts"
      }

      template {
        data        = <<-EOF
          {{ with secret "kvv2-certs/data/root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/ca.crt"
        change_mode = "restart"
      }

      vault {}

      # https://developer.hashicorp.com/nomad/docs/job-specification/volume_mount
      volume_mount {
        volume      = "certs"
        destination = "/mnt/acmeStorage"
      }

      restart {
        attempts = 3
        delay    = "10s"
      }

    }
  }
}