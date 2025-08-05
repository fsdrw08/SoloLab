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
      value_file = "./podman-exporters/values-sololab.yaml"
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

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_records = [
  {
    zone = "day0.sololab."
    name = "prometheus-podman-exporter.day0.sololab."
    type = "A"
    ttl  = 86400
    records = [
      "192.168.255.10"
    ]
  }
]
