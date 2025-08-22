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

podman_kubes = [
  {
    helm = {
      name       = "grafana"
      chart      = "../../../HelmWorkShop/helm-charts/charts/grafana"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2-certs"
            name  = "grafana.day1.sololab"
          }
          value_sets = [
            {
              name          = "grafana.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "grafana.tls.contents.grafana\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "grafana.tls.contents.grafana\\.key"
              value_ref_key = "private_key"
            },
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/grafana-aio.yaml"
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
            Description           = "Grafana instance"
            Documentation         = "https://docs.grafana.org"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            # kube
            yaml          = "grafana-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day1.sololab/v1/identity/oidc/.well-known/openid-configuration"
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 15-20 -n 1) && podman healthcheck run grafana-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "grafana"
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
    name = "grafana.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1-fcos.node.consul."
    ]
  }
]
