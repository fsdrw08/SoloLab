prov_vault = {
  address         = "https://vault.day0.sololab:8200"
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
    name       = "traefik"
    chart      = "../../../HelmWorkShop/helm-charts/charts/traefik"
    value_file = "./podman-traefik/values-sololab.yaml"
    tls = {
      value_sets = [
        {
          name          = "traefik.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "traefik.tls.contents.day1\\.crt"
          value_ref_key = "cert"
        },
        {
          name          = "traefik.tls.contents.day1\\.key"
          value_ref_key = "private_key"
        }
      ]
      vault_kvv2 = {
        mount = "kvv2/certs"
        name  = "*.day1.sololab"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "./podman-traefik/quadlet.kube"
          vars = {
            # unit
            Description           = "Traefik Proxy"
            Documentation         = "https://docs.traefik.io"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "traefik-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # Network    = "podman"
            # Network = "pasta:--map-host-loopback=169.254.1.3"
            # service
            ExecStartPreVault  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab/v1/identity/oidc/.well-known/openid-configuration"
            ExecStartPreConsul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://consul.day0.sololab/v1/catalog/services"
            ExecStartPost      = "/bin/bash -c \"sleep $(shuf -i 8-13 -n 1) && podman healthcheck run traefik-proxy\""
            Restart            = "on-failure"
          }
        },
      ]
      service = {
        name   = "traefik"
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
    name = "traefik.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1.node.consul."
    ]
  },
]
