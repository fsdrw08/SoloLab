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
    task "plugin" {
      driver = "docker"
      config {
        image = "zot.day0.sololab/sig-storage/nfsplugin:v4.11.0"
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
