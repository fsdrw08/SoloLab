# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://support.hashicorp.com/hc/en-us/articles/22557185128083-Nomad-NFS-CSI-Volume
job "nfs-controller" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "nfs-controller" {
    task "plugin" {
      service {
        provider = "consul"
        name     = "nfs-controller"
        tags = [
          "log",
        ]
      }

      driver = "podman"

      # https://github.com/thatsk/nfs-csi-nomad/blob/main/nfs-controller.nomad
      config {
        image = "zot.day0.sololab/sig-storage/nfsplugin:v4.12.1"
        args = [
          "--drivername=nfs.csi.k8s.io",
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--nodeid=${attr.unique.hostname}",
          "-v=5",
        ]
        privileged = true
      }

      csi_plugin {
        id        = "nfs"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100
        memory = 32
      }
    }
  }
}

# https://github.com/livioribeiro/nomad-lxd-terraform/blob/0c792716c9824c4c59de349d27b6aa1d1c16b09d/modules/nomad_jobs/jobs/rocketduck-nfs/controller.nomad.hcl