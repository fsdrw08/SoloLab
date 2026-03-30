variable "metrics_auth_header" {
  type = string
}
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
    # Custom ssl certificates not properly handled by aws sdk using s3 blob store
    # ref: https://github.com/sonatype/nexus-public/issues/894
    # which means nexus3 fail to connect private minio with tls even after update ssl truststore via web api
    # work around:
    # in order to make nexus3 connect private minio with tls, 
    # need to update default truststore (the cacerts) to trust private ca cert by root user, 
    # then copy it to cacerts volume
    #
    # https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
    task "update-truststore" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      user   = "root"
      driver = "podman"
      config {
        # https://github.com/sonatype/docker-nexus3/blob/b623312ce82a74f877dcaac5b4989b89cd11ecdd/Dockerfile.alpine.java21
        image = "zot.day0.sololab/sonatype/nexus3:3.90.2-alpine"
        volumes = [
          "secrets/sololab.crt:/usr/local/share/ca-certificates/sololab.crt:ro",
        ]
        command = "/bin/sh"
        args = [
          "-c",
          "keytool -import -noprompt -trustcacerts -alias sololab -file /usr/local/share/ca-certificates/sololab.crt -keystore /etc/ssl/certs/java/cacerts -storepass changeit && cp /etc/ssl/certs/java/cacerts /mnt/etc/ssl/certs/java/cacerts",
        ]
      }

      template {
        data        = <<-EOH
        {{with secret "kvv2_certs/data/sololab_root"}}{{.Data.data.ca}}{{end}}
        EOH
        destination = "secrets/sololab.crt"
      }
      vault {}

      volume_mount {
        volume        = "nexus-cacerts"
        destination   = "/mnt/etc/ssl/certs/java"
        selinux_label = "Z"
      }
    }
    task "wait4x-postgresql" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day0.sololab/wait4x/wait4x:3.6.0"
        args = [
          "postgresql",
          "${URL}",
        ]
      }
      template {
        # https://help.sonatype.com/en/install-nexus-repository-with-a-postgresql-database.html
        data = <<-EOH
        # Lines starting with a # are ignored

        # Empty lines are also ignored
        URL=postgres://{{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_name}}{{end}}:{{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_password}}{{end}}@pgbouncer-day2.service.consul:6432/nexus?sslmode=require
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}
    }
    task "wait4x-ldap" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day0.sololab/wait4x/wait4x:3.6.0"
        args = [
          "tcp",
          "lldap.day0.sololab:636",
        ]
      }
    }
    task "wait4x-minio" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day0.sololab/wait4x/wait4x:3.6.0"
        args = [
          "http",
          "https://minio-api.day0.sololab/minio/health/live",
          # https://github.com/wait4x/wait4x/pull/35
          "--insecure-skip-tls-verify",
          "--expect-status-code",
          "200",
        ]
      }
    }
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
          "metrics-exposing-general",
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

          prom_target_scheme       = "https"
          prom_target_address      = "nexus3.service.consul"
          prom_target_metrics_path = "service/rest/metrics/prometheus"
        }
      }

      driver = "podman"
      config {
        # https://github.com/sonatype/docker-nexus3/blob/b623312ce82a74f877dcaac5b4989b89cd11ecdd/Dockerfile.alpine.java21
        image = "zot.day0.sololab/sonatype/nexus3:3.90.2-alpine"
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

          # ref: https://help.sonatype.com/en/prometheus.html
          # add a basic auth header middleware to make metric request without authentication from prometheus
          "traefik.http.middlewares.nexus3-metric-basicAuthHeader.headers.customRequestHeaders.Authorization" = "${var.metrics_auth_header}"
          "traefik.http.routers.nexus3-metric.entrypoints"                                                    = "webSecure"
          "traefik.http.routers.nexus3-metric.rule"                                                           = "Host(`nexus3.service.consul`) && Path(`/service/rest/metrics/prometheus`)"
          "traefik.http.routers.nexus3-metric.tls"                                                            = "true"
          "traefik.http.routers.nexus3-metric.middlewares"                                                    = "nexus3-metric-basicAuthHeader@docker"
          "traefik.http.routers.nexus3-metric.service"                                                        = "nexus3"

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

      volume_mount {
        volume        = "nexus-cacerts"
        destination   = "/etc/ssl/certs/java"
        selinux_label = "Z"
      }
      # https://github.com/nexus3-org/nexus3-docker/tree/v1.10.0-1?tab=readme-ov-file#data-persistence
      volume_mount {
        volume        = "nexus"
        destination   = "/nexus-data"
        selinux_label = "Z"
      }
    }
    volume "nexus-cacerts" {
      type            = "csi"
      source          = "nexus-cacerts"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    volume "nexus" {
      type            = "csi"
      source          = "nexus"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}