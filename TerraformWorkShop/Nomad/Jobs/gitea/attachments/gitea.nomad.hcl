variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "gitea" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "ci"
  }

  group "gitea" {
    network {
      port "gitea-ssh" {
        static = 2222
      }
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "gitea" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "gitea"
        # need to set address_mode to "host" to use day1 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 3000
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(meilisearch.day2.sololab) & re-encrypt(server transport(meilisearch-day2.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.gitea-redirect.entryPoints=web",
          "traefik.http.routers.gitea-redirect.rule=Host(`gitea.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitea-redirect.middlewares=toHttps@file",

          "traefik.http.routers.gitea.entryPoints=webSecure",
          "traefik.http.routers.gitea.rule=Host(`gitea.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitea.tls.certresolver=internal",

          "traefik.http.services.gitea.loadbalancer.server.scheme=https",
          "traefik.http.services.gitea.loadbalancer.server.port=443",
          "traefik.http.services.gitea.loadBalancer.serversTransport=consul-service@file",
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

      driver = "podman"
      config {
        # https://github.com/go-gitea/gitea/blob/v1.25.4/Dockerfile.rootless
        image = "zot.day0.sololab/gitea/gitea:1.25.4-rootless"
        labels = {
          "traefik.enable"                                  = "true"
          "traefik.http.routers.gitea-redirect.entrypoints" = "web"
          "traefik.http.routers.gitea-redirect.rule"        = "(Host(`gitea.ci.sololab`)||Host(`gitea.service.consul`))"
          "traefik.http.routers.gitea-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.gitea-redirect.service"     = "gitea"

          "traefik.http.routers.gitea.entryPoints" = "webSecure"
          "traefik.http.routers.gitea.rule"        = "(Host(`gitea.ci.sololab`)||Host(`gitea.service.consul`))"
          "traefik.http.routers.gitea.tls"         = "true"
          "traefik.http.routers.gitea.service"     = "gitea"

          "traefik.http.services.gitea.loadbalancer.server.port" = "3000"
        }
        ports = [
          "gitea-ssh",
        ]
        volumes = [
          # Customization files should be placed in /var/lib/gitea/custom directory
          # https://docs.gitea.com/1.25/installation/install-with-docker-rootless#customization
          # https://docs.gitea.com/1.25/administration/customizing-gitea#customizing-the-git-configuration
          # https://docs.gitea.com/installation/install-with-docker-rootless#customization
          # https://docs.gitea.com/administration/customizing-gitea#customizing-the-git-configuration
          "local/app.ini:/var/lib/gitea/custom/app.ini",
        ]
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 300
      }

      template {
        data        = var.config
        destination = "local/app.ini"
      }
      vault {}

      volume_mount {
        volume        = "gitea"
        destination   = "/var/lib/gitea"
        selinux_label = "Z"
      }
    }
    volume "gitea" {
      type            = "csi"
      source          = "gitea-data"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}