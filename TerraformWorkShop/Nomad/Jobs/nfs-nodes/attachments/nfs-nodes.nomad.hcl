# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://support.hashicorp.com/hc/en-us/articles/22557185128083-Nomad-NFS-CSI-Volume
job "nfs-nodes" {
  datacenters = ["dc1"]
  type        = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "nfs-nodes" {
    service {
      provider = "consul"
      name     = "nfs-csi-plugin-node"
    }

    shutdown_delay = "10s"

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#socket
    task "plugin" {
      driver = "podman"
      config {
        image = "zot.day0.sololab/sig-storage/nfsplugin:v4.12.1"
        args = [
          "--drivername=nfs.csi.k8s.io",
          "--endpoint=unix:///csi/csi.sock",
          "--logtostderr",
          "--nodeid=${attr.unique.hostname}",
          "--v=5",
        ]
        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged = true
      }
      csi_plugin {
        id        = "nfs"
        type      = "node"
        mount_dir = "/csi"
      }
      resources {
        cpu    = 100
        memory = 32
      }
    }
  }
}
