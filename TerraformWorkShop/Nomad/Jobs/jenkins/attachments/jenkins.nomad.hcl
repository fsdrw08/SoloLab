variable "jenkins_plugins" {
  type = string
}
variable "jcasc_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "jenkins" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day3"
  }
  group "jenkins" {
    # https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
    # https://github.com/hashicorp/nomad-pack-community-registry/blob/2e5e93a5589d4b26c6ea5a39db22f2a80a176f77/packs/jenkins/templates/jenkins.nomad.tpl
    task "install-plugins" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 600
      }

      driver = "podman"
      config {
        # https://www.jenkins.io/doc/upgrade-guide/
        # https://hub.docker.com/r/jenkins/jenkins
        image   = "zot.day0.sololab/jenkins/jenkins:2.541.3-lts"
        command = "jenkins-plugin-cli"
        args    = ["-f", "/var/jenkins_home/plugins.txt", "--plugin-download-directory", "/var/jenkins_home/plugins/"]
        volumes = [
          "local/plugins.txt:/var/jenkins_home/plugins.txt",
        ]
      }

      env {
        TZ        = "Asia/Shanghai"
        JAVA_OPTS = "-Xmx600m"
        # https://cloud.tencent.com/developer/article/2040515
        # https://jenkins-update.davidz.cn/
        JENKINS_UC          = "https://mirrors.huaweicloud.com/jenkins/updates/update-center.json"
        JENKINS_UC_DOWNLOAD = "https://mirrors.huaweicloud.com/jenkins"
      }

      template {
        data        = var.jenkins_plugins
        destination = "local/plugins.txt"
        change_mode = "noop"
      }

      volume_mount {
        volume      = "jenkins"
        destination = "/var/jenkins_home"
        read_only   = false
      }
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "jenkins" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "jenkins"
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
        #   traefik.day1 -[http route: decrypt(jenkins.day3.sololab) & re-encrypt(server transport(jenkins.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          # "metrics-exposing-general",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.jenkins-redirect.entryPoints=web",
          "traefik.http.routers.jenkins-redirect.rule=Host(`jenkins.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.jenkins-redirect.middlewares=toHttps@file",

          "traefik.http.routers.jenkins.entryPoints=webSecure",
          "traefik.http.routers.jenkins.rule=Host(`jenkins.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.jenkins.tls.certresolver=internal",

          "traefik.http.services.jenkins.loadbalancer.server.scheme=https",
          "traefik.http.services.jenkins.loadbalancer.server.port=443",
          "traefik.http.services.jenkins.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "jenkins.service.consul"
          prom_blackbox_health_check_path = "/"

          # prom_target_scheme       = "https"
          # prom_target_address      = "jenkins.service.consul"
          # prom_target_metrics_path = "service/rest/metrics/prometheus"
        }
      }

      driver = "podman"
      config {
        # https://www.jenkins.io/doc/upgrade-guide/
        # https://hub.docker.com/r/jenkins/jenkins
        image = "zot.day0.sololab/jenkins/jenkins:2.541.3-lts"
        labels = {
          "traefik.enable"                                    = "true"
          "traefik.http.routers.jenkins-redirect.entrypoints" = "web"
          "traefik.http.routers.jenkins-redirect.rule"        = "(Host(`jenkins.${attr.unique.hostname}.sololab`)||Host(`jenkins.service.consul`))"
          "traefik.http.routers.jenkins-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.jenkins-redirect.service"     = "jenkins"

          "traefik.http.routers.jenkins.entryPoints" = "webSecure"
          "traefik.http.routers.jenkins.rule"        = "(Host(`jenkins.${attr.unique.hostname}.sololab`)||Host(`jenkins.service.consul`))"
          "traefik.http.routers.jenkins.tls"         = "true"
          "traefik.http.routers.jenkins.service"     = "jenkins"

          "traefik.http.services.jenkins.loadbalancer.server.port" = "8080"
        }
        volumes = [
          "local/jcasc.yaml:/var/jenkins_home/jenkins.yaml",
        ]
      }
      env {
        TZ = "Asia/Shanghai"
        # https://cloud.tencent.com/developer/article/2040515
        # https://jenkins-update.davidz.cn/
        JAVA_OPTS           = "-Xmx600m -Dhudson.model.DownloadService.noSignatureCheck=true -Djenkins.install.runSetupWizard=false"
        JENKINS_UC          = "https://mirrors.huaweicloud.com/jenkins/updates/update-center.json"
        JENKINS_UC_DOWNLOAD = "https://mirrors.huaweicloud.com/jenkins"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 600
      }

      template {
        data        = var.jcasc_config
        change_mode = "noop"
        destination = "local/jcasc.yaml"
      }

      # https://github.com/jenkins-org/jenkins-docker/tree/v1.10.0-1?tab=readme-ov-file#data-persistence
      volume_mount {
        volume      = "jenkins"
        destination = "/var/jenkins_home"
        read_only   = false
      }
    }
    volume "jenkins" {
      type            = "host"
      source          = "jenkins"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}