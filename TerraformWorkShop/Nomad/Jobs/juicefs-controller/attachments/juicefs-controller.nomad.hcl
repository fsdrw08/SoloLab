# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://juicefs.com/docs/csi/csi-in-nomad
job "juicefs-controller" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day3"
  }

  group "juicefs-controller" {
    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "plugin" {
      service {
        provider = "consul"
        name     = "juicefs-controller"
        tags = [
          "log",
        ]
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      # https://github.com/thatsk/nfs-csi-nomad/blob/main/nfs-controller.nomad
      config {
        image = "zot.day1.sololab/juicedata/juicefs-csi-driver:v0.31.8"
        args = [
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--nodeid=${attr.unique.hostname}",
          "--v=5",
          "--by-process=true"
        ]
        privileged = true
      }

      csi_plugin {
        id        = "juicefs"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100
        memory = 100
      }
      env {
        POD_NAME = "csi-controller"
      }

      template {
        change_mode = "noop"
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/sololab_root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/tls/ca.crt"
      }

      vault {}

    }
  }
}

# https://github.com/livioribeiro/nomad-lxd-terraform/blob/0c792716c9824c4c59de349d27b6aa1d1c16b09d/modules/nomad_jobs/jobs/rocketduck-nfs/controller.nomad.hcl