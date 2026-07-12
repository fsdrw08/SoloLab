variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "gitea-runner" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "regexp"
    value     = "^day5.*"
  }

  group "gitea-runner" {
    task "wait4x-gitea" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day1.sololab/wait4x/wait4x:3.6.0"
        args = [
          "http",
          "https://gitea.day4.sololab/api/v1/version",
          # https://github.com/wait4x/wait4x/pull/35
          "--insecure-skip-tls-verify",
          "--expect-status-code",
          "200",
        ]
      }
      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 100
        # Specifies the memory required in MB
        memory = 50
      }
    }

    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "gitea-runner" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "gitea-runner"
        # need to set address_mode to "host" to make this service resolve to host ip address in consul
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 9101
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        tags = [
          "${attr.unique.hostname}",
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          # "traefik.enable=true",
          # "traefik.http.routers.gitea-runner-redirect.entryPoints=web",
          # "traefik.http.routers.gitea-runner-redirect.rule=Host(`gitea-runner.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.gitea-runner-redirect.middlewares=toHttps@file",

          # "traefik.http.routers.gitea-runner.entryPoints=webSecure",
          # "traefik.http.routers.gitea-runner.rule=Host(`gitea-runner.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.gitea-runner.tls.certresolver=internal",

          # "traefik.http.services.gitea-runner.loadbalancer.server.scheme=https",
          # "traefik.http.services.gitea-runner.loadbalancer.server.port=443",
          # "traefik.http.services.gitea-runner.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "${attr.unique.hostname}.gitea-runner.service.consul"
          prom_blackbox_health_check_path = "/metrics"

          prom_target_scheme       = "https"
          prom_target_address      = "${attr.unique.hostname}.gitea-runner.service.consul"
          prom_target_metrics_path = "metrics"
        }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://gitea.com/gitea/runner/src/tag/v2.0.0/Dockerfile
        image = "zot.day1.sololab/gitea/runner:2.0.0"
        labels = {
          "traefik.enable"                                         = "true"
          "traefik.http.routers.gitea-runner-redirect.entrypoints" = "web"
          "traefik.http.routers.gitea-runner-redirect.rule"        = "Host(`gitea-runner.service.consul`)"
          "traefik.http.routers.gitea-runner-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.gitea-runner-redirect.service"     = "gitea-runner"

          "traefik.http.routers.gitea-runner.entryPoints" = "webSecure"
          "traefik.http.routers.gitea-runner.rule"        = "Host(`gitea-runner.service.consul`)"
          "traefik.http.routers.gitea-runner.tls"         = "true"
          "traefik.http.routers.gitea-runner.service"     = "gitea-runner"

          "traefik.http.services.gitea-runner.loadbalancer.server.port" = "9101"
        }
      }

      env {
        CONFIG_FILE        = "/local/config.yaml"
        GITEA_INSTANCE_URL = "https://gitea.day4.sololab"
        # https://gitea.com/gitea/runner/issues/634
        SSL_CERT_FILE = "/secrets/sololab.crt"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 600
        # Specifies the memory required in MB
        memory = 300
      }
      # https://developer.hashicorp.com/nomad/docs/job-specification/template
      template {
        change_mode = "noop"
        data        = var.config
        destination = "local/config.yaml"
        uid         = 0
        gid         = 0
      }
      template {
        change_mode = "restart"
        data        = <<-EOF
          GITEA_RUNNER_REGISTRATION_TOKEN={{ with secret "kvv2_gitea/data/token-instance_runner" }}{{ .Data.data.token }}{{ end }}
        EOF
        destination = "secrets/file.env"
        env         = true
      }
      template {
        change_mode = "noop"
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/sololab_root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/sololab.crt"
      }
      vault {}

      volume_mount {
        volume        = "gitea-runner"
        destination   = "/data"
        selinux_label = "Z"
      }
    }
    volume "gitea-runner" {
      type            = "host"
      source          = "hvol-gitea-runner"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}