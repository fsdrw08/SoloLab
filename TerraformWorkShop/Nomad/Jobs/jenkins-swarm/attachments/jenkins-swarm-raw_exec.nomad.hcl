variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "jenkins-swarm" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  # https://developer.hashicorp.com/nomad/docs/job-specification/constraint
  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "regexp"
    value     = "^day4"
  }
  group "jenkins-swarm" {
    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "jenkins-swarm" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "jenkins-swarm"
        # need to set address_mode to "host" to use day1 traefik's server transport
        # address_mode = "host"

        # # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        # check {
        #   address_mode   = "driver"
        #   type           = "tcp"
        #   port           = 8080
        #   interval       = "180s"
        #   timeout        = "2s"
        #   initial_status = "passing"
        # }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(jenkins.day3.sololab) & re-encrypt(server transport(jenkins.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        # tags = [
        #   "metrics-exposing-blackbox",
        #   # "metrics-exposing-general",
        #   "log",

        #   "traefik.enable=true",
        #   "traefik.http.routers.jenkins-redirect.entryPoints=web",
        #   "traefik.http.routers.jenkins-redirect.rule=Host(`jenkins.${attr.unique.hostname}.sololab`)",
        #   "traefik.http.routers.jenkins-redirect.middlewares=toHttps@file",

        #   "traefik.http.routers.jenkins.entryPoints=webSecure",
        #   "traefik.http.routers.jenkins.rule=Host(`jenkins.${attr.unique.hostname}.sololab`)",
        #   "traefik.http.routers.jenkins.tls.certresolver=internal",

        #   "traefik.http.services.jenkins.loadbalancer.server.scheme=https",
        #   "traefik.http.services.jenkins.loadbalancer.server.port=443",
        #   "traefik.http.services.jenkins.loadBalancer.serversTransport=consul-service@file",
        # ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "jenkins.service.consul"
        #   prom_blackbox_health_check_path = "/"

        #   # prom_target_scheme       = "https"
        #   # prom_target_address      = "jenkins.service.consul"
        #   # prom_target_metrics_path = "service/rest/metrics/prometheus"
        # }
      }

      user = "podmgr"

      # https://developer.hashicorp.com/nomad/docs/job-declare/task-driver/raw_exec
      driver = "raw_exec"
      artifact {
        source = "https://jenkins.service.consul/swarm/swarm-client.jar"
      }
      config {
        command = "java"
        args = [
          "-Xmx800m",
          "-Xms256m",
          "-jar",
          "${NOMAD_TASK_DIR}/swarm-client.jar",
          "-config",
          "${NOMAD_TASK_DIR}/config.yaml",
        ]
        work_dir = "/home/podmgr"
      }
      env {
        XDG_RUNTIME_DIR = "/run/user/1001"
        XDG_CONFIG_HOME = "/home/podmgr/.config"
        XDG_DATA_HOME   = "/home/podmgr/.local/share"
      }

      template {
        data        = var.config
        destination = "local/config.yaml"
      }

      template {
        data        = <<-EOF
        SWARM_TOKEN={{ with secret "kvv2_others/jenkins-credential-swarm" }}{{.Data.data.token}}{{ end }}
        EOF
        destination = "secrets/file.env"
        env         = true
      }
      vault {}


      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 600
      }

    }
  }
}