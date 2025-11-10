prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "cockpit"
      chart      = "../../../HelmWorkShop/helm-charts/charts/cockpit"
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
            cert_name = "cockpit.day0"
          }
          value_sets = [
            {
              name          = "cockpit.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "cockpit.secret.tls.contents.server\\.crt"
              value_ref_key = "cert_pem_chain"
            },
            {
              name          = "cockpit.secret.tls.contents.server\\.key"
              value_ref_key = "key_pem"
            }
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/cockpit-aio.yaml"
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
            Description           = "Cockpit is a web-based graphical interface for servers."
            Documentation         = "https://cockpit-project.org/guide/latest/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "cockpit-aio.yaml"
            KubeDownForce = "false"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = ""
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        }
      ]
      service = {
        name   = "cockpit"
        status = "start"
      }
    },
  ]
}
