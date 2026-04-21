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
    # https://developer.hashicorp.com/nomad/docs/job-specification/task
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
        memory = 500
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://www.jenkins.io/doc/upgrade-guide/
        # https://hub.docker.com/r/jenkins/jenkins
        image   = "zot.day0.sololab/jenkins/jenkins:2.555.1-lts"
        command = "jenkins-plugin-cli"
        args    = ["-f", "/var/jenkins_home/plugins.txt", "--plugin-download-directory", "/var/jenkins_home/plugins/"]
        volumes = [
          "local/plugins.txt:/var/jenkins_home/plugins.txt",
        ]
      }

      env {
        TZ        = "Asia/Shanghai"
        JAVA_OPTS = <<-EOF
          -Xmx500m 
          -Dhttp.proxyHost=shellcrash.vyos.sololab 
          -Dhttp.proxyPort=7890 
          -Dhttps.proxyHost=shellcrash.vyos.sololab 
          -Dhttps.proxyPort=7890
          -Dhttp.nonProxyHosts="*.localhost|*.sololab|*.consul"
        EOF
        # https://cloud.tencent.com/developer/article/2040515
        # https://jenkins-update.davidz.cn/
        # JENKINS_UC          = "https://mirrors.huaweicloud.com/jenkins/updates/update-center.json"
        # JENKINS_UC_DOWNLOAD = "https://mirrors.huaweicloud.com/jenkins"
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

    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    # https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
    # https://github.com/hashicorp/nomad-pack-community-registry/blob/2e5e93a5589d4b26c6ea5a39db22f2a80a176f77/packs/jenkins/templates/jenkins.nomad.tpl
    task "update-ca-certificates" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 100
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      user   = "root"
      config {
        # https://www.jenkins.io/doc/upgrade-guide/
        # https://hub.docker.com/r/jenkins/jenkins
        image      = "zot.day0.sololab/jenkins/jenkins:2.555.1-lts"
        entrypoint = "/bin/bash"
        args = [
          "-c",
          <<-EOF
          update-ca-certificates \
          && cp /etc/ssl/certs/ca-certificates.crt /var/jenkins_home/ca-certificates.crt \
          && keytool -import -noprompt -trustcacerts -alias sololab -file /usr/local/share/ca-certificates/sololab.crt -keystore /opt/java/openjdk/lib/security/cacerts -storepass changeit \
          && cp /opt/java/openjdk/lib/security/cacerts /mnt/opt/java/openjdk/lib/security/cacerts
          EOF
        ]
        volumes = [
          "secrets/sololab.crt:/usr/local/share/ca-certificates/sololab.crt",
        ]
      }

      template {
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/sololab_root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/sololab.crt"
        change_mode = "restart"
      }
      vault {}

      volume_mount {
        volume      = "jenkins"
        destination = "/var/jenkins_home"
        read_only   = false
      }
      volume_mount {
        volume        = "jenkins-cacerts"
        destination   = "/mnt/opt/java/openjdk/lib/security"
        selinux_label = "Z"
      }
    }

    network {
      port "jnlp" {
        static = 50000
      }
    }
    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "jenkins" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "jenkins"
        # need to set address_mode to "host" to let consul know the service can be reached by the host IP
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

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://www.jenkins.io/doc/upgrade-guide/
        # https://hub.docker.com/r/jenkins/jenkins
        image = "zot.day0.sololab/jenkins/jenkins:2.555.1-lts"
        ports = [
          "jnlp",
        ]
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
        TZ             = "Asia/Shanghai"
        GIT_SSL_CAINFO = "/var/jenkins_home/ca-certificates.crt"
        # https://cloud.tencent.com/developer/article/2040515
        # https://jenkins-update.davidz.cn/
        JAVA_OPTS = <<-EOF
          -Xmx600m 
          -Dhudson.model.DownloadService.noSignatureCheck=true 
          -Djenkins.install.runSetupWizard=false
          -Dhttp.proxyHost=shellcrash.vyos.sololab 
          -Dhttp.proxyPort=7890 
          -Dhttps.proxyHost=shellcrash.vyos.sololab 
          -Dhttps.proxyPort=7890
          -Dhttp.nonProxyHosts="*.localhost|*.sololab|*.consul"
        EOF
        # JENKINS_UC          = "https://mirrors.huaweicloud.com/jenkins/updates/update-center.json"
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
      vault {}

      volume_mount {
        volume        = "jenkins-cacerts"
        destination   = "/opt/java/openjdk/lib/security"
        selinux_label = "Z"
      }
      # https://github.com/jenkins-org/jenkins-docker/tree/v1.10.0-1?tab=readme-ov-file#data-persistence
      volume_mount {
        volume      = "jenkins"
        destination = "/var/jenkins_home"
        read_only   = false
      }
    }
    volume "jenkins-cacerts" {
      type            = "csi"
      source          = "jenkins-cacerts"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
    volume "jenkins" {
      type            = "csi"
      source          = "jenkins"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}