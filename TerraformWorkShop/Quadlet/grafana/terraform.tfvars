prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "grafana"
    chart      = "../../../HelmWorkShop/helm-charts/charts/grafana"
    value_file = "./podman-grafana/values-sololab.yaml"
    tls = {
      value_sets = [
        {
          name          = "grafana.tls.contents.grafana\\.crt"
          value_ref_key = "cert"
        },
        {
          name          = "grafana.tls.contents.grafana\\.key"
          value_ref_key = "private_key"
        },
      ]
      vault_kvv2 = {
        mount = "kvv2/certs"
        name  = "grafana.day1.sololab"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/grafana-aio.yaml"
}

podman_quadlet = {
  service = {
    name   = "grafana-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-grafana/grafana-container.kube"
      vars = {
        Description   = "Grafana instance"
        Documentation = "https://docs.grafana.org"
        After         = ""
        Wants         = ""
        yaml          = "grafana-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab/v1/identity/oidc/.well-known/openid-configuration"
        # ExecStartPost = "/bin/bash -c \"sleep 5 && podman healthcheck run grafana-server\""
        ExecStartPost = ""
        Restart       = "on-failure"
      }
      dir = "/home/podmgr/.config/containers/systemd"
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
      "day1.node.consul."
    ]
  }
]
