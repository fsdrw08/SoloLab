variable "atlantis_config" {
  type = string
}
variable "terraform_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "atlantis" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day4"
  }

  group "atlantis" {
    task "wait4x-redis" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day1.sololab/wait4x/wait4x:3.6.0"
        args = [
          "redis",
          "redis://atlantis:atlantis@day3.redis.service.consul:6379/1",
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
    task "atlantis" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "atlantis"
        # need to set address_mode to "host" to use day2 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 4141
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day2 -[http route: decrypt(meilisearch.day3.sololab) & re-encrypt(server transport(meilisearch-day3.service.consul)) & ]-> 
        #   traefik.day3 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.atlantis-redirect.entryPoints=web",
          "traefik.http.routers.atlantis-redirect.rule=Host(`atlantis.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.atlantis-redirect.middlewares=toHttps@file",

          "traefik.http.routers.atlantis.entryPoints=webSecure",
          "traefik.http.routers.atlantis.rule=Host(`atlantis.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.atlantis.tls.certresolver=internal",

          "traefik.http.services.atlantis.loadbalancer.server.scheme=https",
          "traefik.http.services.atlantis.loadbalancer.server.port=443",
          "traefik.http.services.atlantis.loadBalancer.serversTransport=consul-service@file",
        ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "atlantis.service.consul"
        #   prom_blackbox_health_check_path = "/health"

        #   prom_target_scheme       = "https"
        #   prom_target_address      = "atlantis.service.consul"
        #   prom_target_metrics_path = "metrics"
        # }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://github.com/runatlantis/atlantis/blob/v0.43.0/Dockerfile
        image = "zot.day1.sololab/runatlantis/atlantis:v0.43.0"
        labels = {
          "traefik.enable"                                     = "true"
          "traefik.http.routers.atlantis-redirect.entrypoints" = "web"
          "traefik.http.routers.atlantis-redirect.rule"        = "(Host(`atlantis.day4.sololab`)||Host(`atlantis.service.consul`))"
          "traefik.http.routers.atlantis-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.atlantis-redirect.service"     = "atlantis"

          "traefik.http.routers.atlantis.entryPoints" = "webSecure"
          "traefik.http.routers.atlantis.rule"        = "(Host(`atlantis.day4.sololab`)||Host(`atlantis.service.consul`))"
          "traefik.http.routers.atlantis.tls"         = "true"
          "traefik.http.routers.atlantis.service"     = "atlantis"

          "traefik.http.services.atlantis.loadbalancer.server.port" = "4141"
        }
        command = "server"
        args = [
          "--config=/local/config.yaml",
        ]
      }

      env {
        SSL_CERT_FILE      = "/secrets/sololab.crt"
        TF_CLI_CONFIG_FILE = "/local/.terraformrc"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 300
      }

      template {
        change_mode = "noop"
        data        = var.atlantis_config
        destination = "local/config.yaml"
        uid         = 100
        gid         = 1000
      }
      template {
        change_mode = "noop"
        data        = var.terraform_config
        destination = "local/.terraformrc"
        uid         = 100
        gid         = 1000
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
        volume = "atlantis-data"
        # https://www.runatlantis.io/docs/server-configuration.html#data-dir
        destination   = "/home/atlantis/.atlantis"
        selinux_label = "Z"
      }
    }
    volume "atlantis-data" {
      type            = "csi"
      source          = "csi-atlantis-data"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}