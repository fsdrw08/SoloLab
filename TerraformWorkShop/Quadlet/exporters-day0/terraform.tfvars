prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          # template = "../templates/quadlet.kube"
          template = "./attachments/prometheus-podman-exporter.container"
          vars = {
            # unit
            Description           = "Prometheus podman exporter"
            Documentation         = "https://github.com/containers/prometheus-podman-exporter"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "no"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = "host"
          }
        },
      ]
      service = {
        name   = "prometheus-podman-exporter"
        status = "start"
      }
    },
  ]
}
