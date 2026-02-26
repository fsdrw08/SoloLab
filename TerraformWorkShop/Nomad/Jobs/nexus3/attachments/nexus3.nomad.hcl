# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "nexus3" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day3"
  }

  group "nexus3" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "nexus3" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "nexus3"
        # need to set address_mode to "host" to use day1 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 8081
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(nexus3.day3.sololab) & re-encrypt(server transport(nexus3.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.nexus3-redirect.entryPoints=web",
          "traefik.http.routers.nexus3-redirect.rule=Host(`nexus3.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.nexus3-redirect.middlewares=toHttps@file",

          "traefik.http.routers.nexus3.entryPoints=webSecure",
          "traefik.http.routers.nexus3.rule=Host(`nexus3.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.nexus3.tls.certresolver=internal",

          "traefik.http.services.nexus3.loadbalancer.server.scheme=https",
          "traefik.http.services.nexus3.loadbalancer.server.port=443",
          "traefik.http.services.nexus3.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "nexus3.service.consul"
          prom_blackbox_health_check_path = "/"
        }
      }

      driver = "podman"
      config {
        # https://github.com/sonatype/docker-nexus3/blob/b623312ce82a74f877dcaac5b4989b89cd11ecdd/Dockerfile.alpine.java21
        image = "zot.day0.sololab/sonatype/nexus3:3.89.1-alpine"
        labels = {
          "traefik.enable"                                   = "true"
          "traefik.http.routers.nexus3-redirect.entrypoints" = "web"
          "traefik.http.routers.nexus3-redirect.rule"        = "(Host(`nexus3.${attr.unique.hostname}.sololab`)||Host(`nexus3.service.consul`))"
          "traefik.http.routers.nexus3-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.nexus3-redirect.service"     = "nexus3"

          "traefik.http.routers.nexus3.entryPoints" = "webSecure"
          "traefik.http.routers.nexus3.rule"        = "(Host(`nexus3.${attr.unique.hostname}.sololab`)||Host(`nexus3.service.consul`))"
          "traefik.http.routers.nexus3.tls"         = "true"
          "traefik.http.routers.nexus3.service"     = "nexus3"

          "traefik.http.services.nexus3.loadbalancer.server.port" = "8081"
        }
      }
      env {
        TZ                      = "Asia/Shanghai"
        INSTALL4J_ADD_VM_PARAMS = "-Xms300m -Xmx700m -XX:MaxDirectMemorySize=700m -Djava.util.prefs.userRoot=/nexus-data/javaprefs"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 1000
        # Specifies the memory required in MB
        memory = 800
      }

      template {
        # https://help.sonatype.com/en/install-nexus-repository-with-a-postgresql-database.html
        data = <<-EOH
        # Lines starting with a # are ignored

        # Empty lines are also ignored
        NEXUS_DATASTORE_NEXUS_JDBCURL=jdbc:postgresql://pgbouncer-day2.service.consul:6432/nexus??useSSL=true&sslMode=require
        NEXUS_DATASTORE_NEXUS_USERNAME={{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_name}}{{end}}
        NEXUS_DATASTORE_NEXUS_PASSWORD={{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_password}}{{end}}
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}

      # https://github.com/nexus3-org/nexus3-docker/tree/v1.10.0-1?tab=readme-ov-file#data-persistence
      volume_mount {
        volume        = "nexus"
        destination   = "/nexus-data"
        selinux_label = "Z"
      }
    }
    volume "nexus" {
      type            = "host"
      source          = "nexus"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}