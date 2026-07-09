# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "gitea-runner-cache" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day4"
  }

  group "gitea-runner-cache" {
    # network {
    #   port "gitea-runner-cache" {
    #     static = 8088
    #   }
    # }

    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "gitea-runner-cache" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "gitea-runner-cache"
        # need to set address_mode to "host" to make this service resolve to host ip address in consul
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 8088
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        tags = [
          # "metrics-exposing-blackbox",
          # "metrics-exposing-general",
          "log",

          # "traefik.enable=true",
          # "traefik.http.routers.gitea-runner-cache-redirect.entryPoints=web",
          # "traefik.http.routers.gitea-runner-cache-redirect.rule=Host(`gitea-runner.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.gitea-runner-cache-redirect.middlewares=toHttps@file",

          # "traefik.http.routers.gitea-runner-cache.entryPoints=webSecure",
          # "traefik.http.routers.gitea-runner-cache.rule=Host(`gitea-runner.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.gitea-runner-cache.tls.certresolver=internal",

          # "traefik.http.services.gitea-runner-cache.loadbalancer.server.scheme=https",
          # "traefik.http.services.gitea-runner-cache.loadbalancer.server.port=443",
          # "traefik.http.services.gitea-runner-cache.loadBalancer.serversTransport=consul-service@file",
        ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "gitea.service.consul"
        #   prom_blackbox_health_check_path = "/health"

        #   prom_target_scheme       = "https"
        #   prom_target_address      = "gitea.service.consul"
        #   prom_target_metrics_path = "metrics"
        # }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://gitea.com/gitea/runner/src/tag/v2.0.0/Dockerfile
        image = "zot.day1.sololab/gitea/runner:2.0.0"
        labels = {
          "traefik.enable"                                           = "true"
          "traefik.http.routers.gitea-runner-cache-http.entrypoints" = "web"
          "traefik.http.routers.gitea-runner-cache-http.rule"        = "Host(`gitea-runner-cache.service.consul`)"
          "traefik.http.routers.gitea-runner-cache-http.service"     = "gitea-runner-cache"

          "traefik.http.routers.gitea-runner-cache.entryPoints" = "webSecure"
          "traefik.http.routers.gitea-runner-cache.rule"        = "Host(`gitea-runner.service.consul`)"
          "traefik.http.routers.gitea-runner-cache.tls"         = "true"
          "traefik.http.routers.gitea-runner-cache.service"     = "gitea-runner-cache"

          "traefik.http.services.gitea-runner-cache.loadbalancer.server.port" = "8088"
        }
        # ports = [
        #   "gitea-runner-cache",
        # ]
        entrypoint = "/bin/sh"
        args = [
          "-c",
          <<-EOF
          gitea-runner cache-server \
            --config /local/config.yaml \
            --host gitea-runner-cache.service.consul \
            --port 8088 \
            --dir /data/cache
          EOF
        ]
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 200
      }
      # https://developer.hashicorp.com/nomad/docs/job-specification/template
      template {
        change_mode = "noop"
        data        = <<-EOF
        cache:
          external_secret: 12345
        EOF
        destination = "local/config.yaml"
        uid         = 0
        gid         = 0
      }
      vault {}

      volume_mount {
        volume        = "gitea-runner-cache"
        destination   = "/data/cache"
        selinux_label = "Z"
      }
    }
    volume "gitea-runner-cache" {
      type            = "host"
      source          = "hvol-gitea-runner-cache"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}