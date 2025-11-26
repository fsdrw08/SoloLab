prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "prometheus-podman-exporter"
      chart      = "../../../HelmWorkShop/helm-charts/charts/prometheus-podman-exporter"
      value_file = "./attachments/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/prometheus-podman-exporter-aio.yaml"
  },
  {
    helm = {
      name       = "prometheus-node-exporter"
      chart      = "../../../HelmWorkShop/helm-charts/charts/prometheus-node-exporter"
      value_file = "./attachments/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/prometheus-node-exporter-aio.yaml"
  }
]


podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          # template = "./attachments/prometheus-podman-exporter.container"
          vars = {
            # unit
            Description           = "Prometheus podman exporter"
            Documentation         = "https://github.com/containers/prometheus-podman-exporter"
            After                 = "podman.socket"
            Wants                 = "podman.socket"
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = ""
            # kube
            yaml          = "prometheus-podman-exporter-aio.yaml"
            KubeDownForce = "false"
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure" # "no"
          }
        },
      ]
      service = {
        name   = "prometheus-podman-exporter"
        status = "start"
      }
    },
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          # template = "./attachments/prometheus-podman-exporter.container"
          vars = {
            # unit
            Description           = "Prometheus node exporter"
            Documentation         = "https://github.com/prometheus/node_exporter"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = ""
            # kube
            yaml          = "prometheus-node-exporter-aio.yaml"
            KubeDownForce = "false"
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure" # "no"
          }
        },
      ]
      service = {
        name   = "prometheus-node-exporter"
        status = "start"
      }
    },
  ]
}
