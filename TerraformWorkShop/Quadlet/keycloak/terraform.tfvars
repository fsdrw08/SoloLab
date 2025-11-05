prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "keycloak-database"
      chart      = "../../../HelmWorkShop/helm-charts/charts/postgresql"
      value_file = "./attachments-postgresql/values-sololab.yaml"
      value_sets = [
        {
          name         = "fullnameOverride"
          value_string = "keycloak-database"
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/keycloak-pg-aio.yaml"
  },
  {
    helm = {
      name       = "keycloak"
      chart      = "../../../HelmWorkShop/helm-charts/charts/keycloak"
      value_file = "./attachments/values-sololab.yaml"
      value_sets = [
        {
          name         = "keycloak.configFiles.config.Database.postgres.Host"
          value_string = "keycloak-database"
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/keycloak-aio.yaml"
  },
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
            Description           = "keycloak PostgreSQL backend"
            Documentation         = ""
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "keycloak-pg-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = ""
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && podman healthcheck run keycloak-database-postgresql\""
            Restart       = "on-failure"
          }
        }
      ]
      service = {
        name   = "keycloak-database"
        status = "start"
      }
    },
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "Open Source Identity and Access Management"
            Documentation         = "https://www.keycloak.org/documentation"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "keycloak-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = ""
            # service
            # ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 10-15 -n 1) && podman healthcheck run keycloak-server\""
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "no"
          }
        }
      ]
      service = {
        name   = "keycloak"
        status = "start"
      }
    },
  ]
}
