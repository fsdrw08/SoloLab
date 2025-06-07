prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = [
  {
    host     = "192.168.255.10"
    port     = 22
    user     = "podmgr"
    password = "podmgr"
  },
  {
    host     = "192.168.255.20"
    port     = 22
    user     = "podmgr"
    password = "podmgr"
  }
]

prov_grafana = {
  url  = "https://grafana.day1.sololab"
  auth = "admin:admin"
}

podman_kube = {
  helm = {
    name       = "alloy"
    chart      = "../../../HelmWorkShop/helm-charts/charts/alloy"
    value_file = "./podman-alloy/values-sololab.yaml"
    tls = {
      value_sets = [
        {
          name          = "alloy.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "alloy.tls.contents.alloy\\.crt"
          value_ref_key = "cert"
        },
        {
          name          = "alloy.tls.contents.alloy\\.key"
          value_ref_key = "private_key"
        },
      ]
      vault_kvv2 = {
        mount = "kvv2/certs"
        name  = "alloy.day1.sololab"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/alloy-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "alloy service"
            Documentation         = "https://grafana.com/docs/alloy/v1.8/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "alloy-aio.yaml"
            KubeDownForce = "false"
            PodmanArgs    = "--tls-verify=false"
            Network       = "host"
            # service
            ExecStartPre = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://loki.day1.sololab/ready"
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "alloy"
        status = "start"
      }
    },
    {
      files = [{
        template = "./podman-alloy/prometheus-podman-exporter.container"
        vars = {
          # unit
          Description           = "Prometheus exporter for podman environments exposing containers, pods, images, volumes and networks information."
          Documentation         = "https://github.com/containers/prometheus-podman-exporter?tab=readme-ov-file#installation"
          After                 = ""
          Wants                 = ""
          StartLimitIntervalSec = 120
          StartLimitBurst       = 3
          # service
          ExecStartPre  = ""
          ExecStartPost = ""
          Restart       = "on-failure"
          # container
          PodmanArgs = "--tls-verify=false"
          Network    = "host"
        }
      }]
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
    name = "alloy.day0.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "infra.node.consul."
    ]
  },
  {
    zone = "day1.sololab."
    name = "alloy.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1.node.consul."
    ]
  },
  {
    zone = "day0.sololab."
    name = "prometheus-podman-exporter.day0.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "infra.node.consul."
    ]
  },
  {
    zone = "day1.sololab."
    name = "prometheus-podman-exporter.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1.node.consul."
    ]
  }
]
