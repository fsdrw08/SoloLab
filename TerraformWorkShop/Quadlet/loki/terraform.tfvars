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
          vault_kvv2 = {
            mount = "kvv2-certs"
            name  = "sololab_root"
          }
          value_sets = [
            {
              name          = "loki.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
          ]
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
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            Network    = ""
            PodmanArgs = "--tls-verify=false"
            # kube
            KubeDownForce = "false"
            yaml          = "loki-aio.yaml"
            # service
            ExecStartPre = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://minio-api.day0.sololab/minio/health/live"
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 80-90 -n 1) && podman healthcheck run loki-server \"" # || sleep $(shuf -i 30-35 -n 1) && podman healthcheck run loki-server \""
            Restart       = "on-failure"
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

dns_records = [
  {
    zone = "day1.sololab."
    name = "loki.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "loki-day1.service.consul."
    ]
  }
]
