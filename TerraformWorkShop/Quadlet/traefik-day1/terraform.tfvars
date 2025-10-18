prov_vault = {
  address         = "https://vault.day1.sololab:8200"
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
      name       = "traefik"
      chart      = "../../../HelmWorkShop/helm-charts/charts/traefik"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2-certs"
            name  = "*.service.consul"
          }
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
        },
        {
          vault_kvv2 = {
            mount = "kvv2-consul"
            name  = "token-consul_dns"
          }
          value_sets = [
            {
              name          = "traefik.configFiles.static.providers.consulCatalog.endpoint.token"
              value_ref_key = "token"
            }
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
  }
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "./attachments/quadlet.kube"
          vars = {
            # unit
            Description           = "Traefik Proxy"
            Documentation         = "https://docs.traefik.io"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "traefik-aio.yaml"
            PodmanArgs    = "--tls-verify=false --no-hosts"
            KubeDownForce = "false"
            Network       = "host"
            # Network    = "podman"
            # Network = "pasta:--map-host-loopback=169.254.1.3"
            # service
            ExecStartPreVault  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day1.sololab:8200/v1/identity/oidc/.well-known/openid-configuration"
            ExecStartPreConsul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://consul.service.consul:8501/v1/catalog/services"
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
