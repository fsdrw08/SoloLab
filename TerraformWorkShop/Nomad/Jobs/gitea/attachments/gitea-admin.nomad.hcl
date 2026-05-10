variable "config" {
  type = string
}
variable "init_script" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "gitea-admin" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "batch"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day4"
  }

  group "gitea-admin" {
    task "wait4x-postgresql" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day1.sololab/wait4x/wait4x:3.6.0"
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
        URL=postgres://{{with secret "kvv2_pgsql/data/gitea"}}{{.Data.data.user_name}}{{end}}:{{with secret "kvv2_pgsql/data/gitea"}}{{.Data.data.user_password}}{{end}}@pgbouncer.service.consul:6432/gitea?sslmode=require
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}
    }

    task "gitea-config" {
      driver = "podman"
      config {
        image   = "zot.day1.sololab/gitea/gitea:1.26.1-rootless"
        command = "/bin/bash"
        args    = ["/tmp/gitea-admin.sh"]
        volumes = [
          "local/app.ini:/var/lib/gitea/custom/app.ini",
          "local/gitea-admin.sh:/tmp/gitea-admin.sh",
        ]
        userns = "keep-id:uid=1000,gid=1000"
      }
      template {
        data        = var.config
        destination = "local/app.ini"
      }
      template {
        data        = var.init_script
        destination = "local/gitea-admin.sh"
      }
      vault {}
    }
  }
}