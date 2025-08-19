# https://developer.hashicorp.com/nomad/docs/job-specification/job
job "traefik" {
  datacenters = ["dc1"]
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
    }

    service {
      name = "traefik"
      port = "web"

      check {
        type     = "http"
        path     = "/ping"
        port     = "web"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "podman"

      config {
        image        = "zot.day0.sololab/library/traefik:v3.5.0"
        ports        = ["web", "webSecure"]
        network_mode = "host"

        volumes = [
          "local/traefik.yaml:/etc/traefik/traefik.yaml",
        ]
      }

      template {
        data        = var.static_config
        destination = "local/traefik.yaml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}