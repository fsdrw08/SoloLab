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
  }
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "Prometheus podman exporter"
            Documentation         = "https://github.com/containers/prometheus-podman-exporter"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "prometheus-podman-exporter-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure"
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

prov_etcd = {
  endpoints = "https://etcd-0.day0.sololab:2379"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

dns_records = [
  {
    hostname = "prometheus-podman-exporter.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  }
]
