variable "static_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-traefik
job "traefik" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

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
      name     = "traefik"
      provider = "consul"

      check {
        type     = "http"
        path     = "/ping"
        port     = "traefik"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "certs" {
      type   = "host"
      source = "acme-certs"
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "traefik" {
      driver = "docker"

      config {
        image = "zot.day0.sololab/library/traefik:v3.5.0"
        # ports        = ["web", "webSecure", "traefik"]
        network_mode = "host"

        volumes = [
          "local/traefik.yaml:/etc/traefik/traefik.yml",
          "secrets/ca.crt:/etc/traefik/tls/ca.crt"
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
        data        = var.static_config
        destination = "local/traefik.yaml"
      }

      template {
        data        = <<-EOF
          {{ with secret "kvv2-certs/data/root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/ca.crt"
        change_mode = "restart"
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/volume_mount
      volume_mount {
        volume      = "certs"
        destination = "/mnt/acmeStorage"
      }
    }
  }
}