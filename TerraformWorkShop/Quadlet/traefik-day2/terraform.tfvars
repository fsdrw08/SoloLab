prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_remote = {
  host = "192.168.255.20"
  port = 22
  credential = {
    "user" = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "vm-day2"
        key   = "rootless_username"
      }
    }
    "password" = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "vm-day2"
        key   = "rootless_password"
      }
    }
  }
}

podman_kubes = [
  {
    helm = {
      name       = "traefik"
      chart      = "../../../HelmWorkShop/helm-charts/charts/traefik"
      value_file = "./attachments/values-sololab.yaml"
      value_refers = [
        {
          vault_kvv2 = {
            mount = "kvv2_certs"
            name  = "*.day2.sololab"
          }
          value_sets = [
            {
              name          = "traefik.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "traefik.secret.tls.contents.day2\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "traefik.secret.tls.contents.day2\\.key"
              value_ref_key = "private_key"
            }
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_certs"
            name  = "*.service.consul"
          }
          value_sets = [
            {
              name          = "traefik.secret.tls.contents.consul-root\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "traefik.secret.tls.contents.consul-cert\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "traefik.secret.tls.contents.consul-key\\.key"
              value_ref_key = "private_key"
            }
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_consul"
            name  = "token-consul_dns"
          }
          value_sets = [
            {
              name          = "traefik.configFiles.install.providers.consulCatalog.endpoint.token"
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
            After                 = "podman.socket"
            Wants                 = "podman.socket"
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            PodmanArgs = "--tls-verify=false --no-hosts"
            Network    = ""
            # Network    = "podman"
            # Network = "pasta:--map-host-loopback=169.254.1.3"
            # kube
            yaml          = "traefik-aio.yaml"
            KubeDownForce = "false"
            # service
            ExecStartPreVault  = "/bin/bash -c \"curl -fLsSk --retry-all-errors --retry 20 --retry-delay 30 https://vault.day1.sololab/v1/identity/oidc/.well-known/openid-configuration\""
            ExecStartPreConsul = "/bin/bash -c \"curl -fLsSk --retry-all-errors --retry 20 --retry-delay 30 https://consul.service.consul:8501/v1/catalog/services\""
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
