# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://juicefs.com/docs/csi/csi-in-nomad
job "juicefs-node" {
  datacenters = ["dc1"]
  type        = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day3"
  }

  group "juicefs-node" {
    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "plugin" {
      service {
        provider = "consul"
        name     = "juicefs-node"
        tags = [
          "log",
        ]
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      # https://github.com/thatsk/nfs-csi-nomad/blob/main/nfs-controller.nomad
      config {
        image = "zot.day1.sololab/juicedata/juicefs-csi-driver:v0.31.10"
        args = [
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--v=5",
          "--nodeid=${attr.unique.hostname}",
          "--by-process=true",
        ]
        privileged = true
      }

      csi_plugin {
        id        = "juicefs"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100
        memory = 600
      }
      env {
        POD_NAME = "csi-node"
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