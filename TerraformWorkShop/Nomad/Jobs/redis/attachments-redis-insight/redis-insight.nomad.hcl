# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "redis-insight" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }
  group "redis-insight" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "redis-insight" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "redis-insight"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 5540
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        meta {
          scheme            = "https"
          address           = "redis-insight.service.consul"
          health_check_path = "/api/health"
          # metrics_path      = "metrics"
        }

        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(redis-insight.day2.sololab) & re-encrypt(server transport(redis-insight.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "log",

          "traefik.enable=true",
          "traefik.http.routers.redis-insight-redirect.entryPoints=web",
          "traefik.http.routers.redis-insight-redirect.rule=Host(`redis-insight.day2.sololab`)",
          "traefik.http.routers.redis-insight-redirect.middlewares=toHttps@file",

          "traefik.http.routers.redis-insight.entryPoints=webSecure",
          "traefik.http.routers.redis-insight.rule=Host(`redis-insight.day2.sololab`)",
          "traefik.http.routers.redis-insight.tls.certresolver=internal",

          "traefik.http.services.redis-insight.loadbalancer.server.scheme=https",
          "traefik.http.services.redis-insight.loadbalancer.server.port=443",
          "traefik.http.services.redis-insight.loadBalancer.serversTransport=consul-service@file",
        ]
      }

      user = "1000:1000"

      driver = "podman"
      config {
        image = "zot.day0.sololab/redis/redisinsight:3.0.2"
        labels = {
          "traefik.enable"                                          = "true"
          "traefik.http.routers.redis-insight-redirect.entrypoints" = "web"
          "traefik.http.routers.redis-insight-redirect.rule"        = "Host(`redis-insight.day2.sololab`)"
          "traefik.http.routers.redis-insight-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.redis-insight.service"              = "redis-insight"

          "traefik.http.routers.redis-insight.entryPoints" = "webSecure"
          "traefik.http.routers.redis-insight.rule"        = "Host(`redis-insight.day2.sololab`)"
          "traefik.http.routers.redis-insight.tls"         = "true"
          "traefik.http.routers.redis-insight.service"     = "redis-insight"

          "traefik.http.services.redis-insight.loadbalancer.server.port" = "5540"
        }
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ                = "Asia/Shanghai"
        RI_ENCRYPTION_KEY = "somepassword"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/volume_mount
      volume_mount {
        volume = "redis-insight"
        # https://github.com/redis/RedisInsight/blob/3.0.2/Dockerfile#L55
        destination   = "/data"
        selinux_label = "Z"
      }
    }
    volume "redis-insight" {
      type            = "host"
      source          = "redis-insight"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}