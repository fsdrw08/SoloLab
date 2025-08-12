prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_grafana = {
  url  = "https://grafana.day1.sololab"
  auth = "admin:admin"
}

podman_kubes = [
  {
    helm = {
      name       = "loki"
      chart      = "../../../HelmWorkShop/helm-charts/charts/loki"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          value_sets = [
            {
              name          = "loki.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "loki.tls.contents.loki\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "loki.tls.contents.loki\\.key"
              value_ref_key = "private_key"
            },
          ]
          vault_kvv2 = {
            mount = "kvv2/certs"
            name  = "loki.day1.sololab"
          }
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/loki-aio.yaml"
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
            Description           = "Loki service"
            Documentation         = "https://grafana.com/docs/loki/v3.5.x/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "loki-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "podman"
            # service
            ExecStartPre = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://minio-api.day1.sololab/minio/health/live"
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            # ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 80-90 -n 1) && podman healthcheck run loki-server \"" # || sleep $(shuf -i 30-35 -n 1) && podman healthcheck run loki-server \""
            ExecStartPost = ""
            Restart       = "" # on-failure
          }
        },
      ]
      service = {
        name   = "loki"
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
    zone = "day1.sololab."
    name = "loki.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1-fcos.node.consul."
    ]
  }
]
