prov_remote = {
  host     = "192.168.255.10"
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
          tfstate = {
            backend = {
              type = "local"
              config = {
                path = "../../TLS/RootCA/terraform.tfstate"
              }
            }
            cert_name = "wildcard.day0"
          }
          value_sets = [
            {
              name          = "traefik.secret.tls.contents.\"ca\\.crt\""
              value_ref_key = "ca"
            },
            {
              name          = "traefik.secret.tls.contents.\"day0\\.crt\""
              value_ref_key = "cert_pem_chain"
            },
            {
              name          = "traefik.secret.tls.contents.\"day0\\.key\""
              value_ref_key = "key_pem"
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
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "Traefik Proxy"
            Documentation         = "https://docs.traefik.io"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            PodmanArgs = "--tls-verify=false --no-hosts"
            Network    = ""
            # kube
            yaml          = "traefik-aio.yaml"
            KubeDownForce = "false"
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 8-13 -n 1) && podman healthcheck run traefik-proxy\""
            Restart       = "on-failure"
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
