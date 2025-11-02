prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "zitadel-database"
      chart      = "../../../HelmWorkShop/helm-charts/charts/postgresql"
      value_file = "./attachments-postgresql/values-sololab.yaml"
      value_sets = [
        {
          name         = "fullnameOverride"
          value_string = "zitadel-database"
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/zitadel-pg-aio.yaml"
  },
  {
    helm = {
      name       = "zitadel-backend"
      chart      = "../../../HelmWorkShop/helm-charts/charts/zitadel-backend"
      value_file = "./attachments-zitadel/values-sololab.yaml"
      # secrets = [
      #   {
      #     tfstate = {
      #       backend = {
      #         type = "local"
      #         config = {
      #           path = "../../TLS/RootCA/terraform.tfstate"
      #         }
      #       }
      #       cert_name = "root"
      #     }
      #     value_sets = [
      #       {
      #         name          = "zitadel.secret.contents.ca\\.crt"
      #         value_ref_key = "ca"
      #       },
      #       # {
      #       #   name          = "zitadel.tls.contents.server\\.crt"
      #       #   value_ref_key = "cert_pem_chain"
      #       # },
      #       # {
      #       #   name          = "zitadel.tls.contents.server\\.key"
      #       #   value_ref_key = "key_pem"
      #       # }
      #     ]
      #   }
      # ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/zitadel-backend-aio.yaml"
  },
  {
    helm = {
      name       = "zitadel-frontend"
      chart      = "../../../HelmWorkShop/helm-charts/charts/zitadel-frontend"
      value_file = "./attachments-zitadel-login/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/zitadel-frontend-aio.yaml"
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
            Description           = "Zitadel PostgreSQL backend"
            Documentation         = "https://zitadel.com/docs/self-hosting/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "zitadel-pg-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = ""
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && podman healthcheck run zitadel-database-postgresql\""
            Restart       = "no"
          }
        }
      ]
      service = {
        name   = "zitadel-database"
        status = "start"
      }
    },
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
            yaml          = "zitadel-backend-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = ""
            # service
            # ExecStartPre  = "/usr/bin/bash -c \"while ! exec 3<>/dev/tcp/127.0.0.1/5432; do sleep 5 ; done\""
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 10-20 -n 1) && podman healthcheck run zitadel-backend-api\""
            Restart       = "no"
          }
        }
      ]
      service = {
        name   = "zitadel-backend"
        status = "start"
      }
    },
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "ZITADEL Hosted Login Version 2"
            Documentation         = "https://zitadel.com/docs/self-hosting/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "zitadel-frontend-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = ""
            # service
            # ExecStartPre  = "/usr/bin/bash -c \"while ! exec 3<>/dev/tcp/127.0.0.1/5432; do sleep 5 ; done\""
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 20-25 -n 1) && podman healthcheck run zitadel-frontend-login\""
            Restart       = "no"
          }
        }
      ]
      service = {
        name   = "zitadel-frontend"
        status = "start"
      }
    },
  ]
}
