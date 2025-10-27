prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "zitadel"
      chart      = "../../../HelmWorkShop/helm-charts/charts/zitadel"
      value_file = "./attachments-zitadel/values-sololab.yaml"
      secrets = [
        {
          tfstate = {
            backend = {
              type = "local"
              config = {
                path = "../../TLS/RootCA/terraform.tfstate"
              }
            }
            cert_name = "root"
          }
          value_sets = [
            {
              name          = "zitadel.secret.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            # {
            #   name          = "zitadel.tls.contents.server\\.crt"
            #   value_ref_key = "cert_pem_chain"
            # },
            # {
            #   name          = "zitadel.tls.contents.server\\.key"
            #   value_ref_key = "key_pem"
            # }
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/zitadel-aio.yaml"
  },
  {
    helm = {
      name       = "zitadel-pg"
      chart      = "../../../HelmWorkShop/helm-charts/charts/postgresql"
      value_file = "./attachments-postgresql/values-sololab.yaml"
      value_sets = [
        {
          name         = "fullnameOverride"
          value_string = "tfbackend-pg"
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/tfbackend-pg-aio.yaml"
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
            Description           = "ZITADEL - Identity infrastructure, simplified for you."
            Documentation         = "https://zitadel.com/docs/self-hosting/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "zitadel-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        }
      ]
      service = {
        name   = "zitadel"
        status = "start"
      }
    },
  ]
}
