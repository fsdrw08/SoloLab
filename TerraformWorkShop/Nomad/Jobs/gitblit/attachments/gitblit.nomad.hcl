variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "gitblit" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day3"
  }

  group "gitblit" {
    network {
      port "gitblit-ssh" {
        static = 2222
      }
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "gitblit" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "gitblit"
        # need to set address_mode to "host" to use day1 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 8080
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(gitblit.day3.sololab) & re-encrypt(server transport(gitblit.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.gitblit-redirect.entryPoints=web",
          "traefik.http.routers.gitblit-redirect.rule=Host(`gitblit.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitblit-redirect.middlewares=toHttps@file",

          "traefik.http.routers.gitblit.entryPoints=webSecure",
          "traefik.http.routers.gitblit.rule=Host(`gitblit.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitblit.tls.certresolver=internal",

          "traefik.http.services.gitblit.loadbalancer.server.scheme=https",
          "traefik.http.services.gitblit.loadbalancer.server.port=443",
          "traefik.http.services.gitblit.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "gitblit.service.consul"
          prom_blackbox_health_check_path = "/"
        }
      }

      driver = "podman"
      config {
        # https://github.com/gitblit-org/gitblit-docker/blob/v1.10.0-1/Dockerfile
        image = "zot.day0.sololab/gitblit/gitblit:1.10.0-rpc"
        labels = {
          "traefik.enable"                                    = "true"
          "traefik.http.routers.gitblit-redirect.entrypoints" = "web"
          "traefik.http.routers.gitblit-redirect.rule"        = "(Host(`gitblit.day3.sololab`)||Host(`gitblit.service.consul`))"
          "traefik.http.routers.gitblit-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.gitblit-redirect.service"     = "gitblit"

          # https://github.com/gitblit-org/gitblit/issues/900
          "traefik.http.middlewares.gitblit-HSTSHeader.headers.stsPreload"           = "true"
          "traefik.http.middlewares.gitblit-HSTSHeader.headers.stsSeconds"           = "15768000"
          "traefik.http.middlewares.gitblit-HSTSHeader.headers.stsIncludeSubdomains" = "true"

          "traefik.http.routers.gitblit.entryPoints" = "webSecure"
          "traefik.http.routers.gitblit.rule"        = "(Host(`gitblit.day3.sololab`)||Host(`gitblit.service.consul`))"
          "traefik.http.routers.gitblit.middlewares" = "gitblit-HSTSHeader@docker"
          "traefik.http.routers.gitblit.tls"         = "true"
          "traefik.http.routers.gitblit.service"     = "gitblit"
          # https://github.com/gitblit-org/gitblit-docker/blob/v1.10.0-1/Dockerfile.alpine#L86
          "traefik.http.services.gitblit.loadbalancer.server.port" = "8080"
        }
        ports = [
          "gitblit-ssh",
        ]
        volumes = [
          # Customization files should be placed in /var/opt/gitblit/etc/gitblit.properties
          "local/gitblit.properties:/var/opt/gitblit/etc/gitblit.properties",
        ]
        # tmpfs = [
        #   # https://hub.docker.com/r/gitblit/gitblit#temporary-webapp-data
        #   "/var/opt/gitblit/temp:rw,size=102400k"
        # ]

      }
      env {
        TZ = "Asia/Shanghai"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 500
      }

      template {
        data        = var.config
        destination = "local/gitblit.properties"
      }
      vault {}

      # https://github.com/gitblit-org/gitblit-docker/tree/v1.10.0-1?tab=readme-ov-file#data-persistence
      volume_mount {
        volume        = "gitblit"
        destination   = "/var/opt/gitblit/"
        selinux_label = "Z"
      }
      # volume_mount {
      #   volume        = "gitblit-config"
      # # https://github.com/gitblit-org/gitblit-docker/blob/v1.10.0-1/docker-entrypoint.sh#L155C72-L155C83
      #   destination   = "/var/opt/gitblit/etc" # baseFolder: /var/opt/gitblit/etc
      #   selinux_label = "Z"
      # }
      # volume_mount {
      #   volume        = "gitblit-data"
      #   destination   = "/var/opt/gitblit/srv"
      #   selinux_label = "Z"
      # }
    }
    volume "gitblit" {
      type            = "host"
      source          = "gitblit"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    # volume "gitblit-config" {
    #   type            = "csi"
    #   source          = "gitblit-config"
    #   read_only       = false
    #   attachment_mode = "file-system"
    #   access_mode     = "single-node-writer"
    # }
    # volume "gitblit-data" {
    #   type            = "csi"
    #   source          = "gitblit-data"
    #   read_only       = false
    #   attachment_mode = "file-system"
    #   access_mode     = "single-node-writer"
    # }
  }
}