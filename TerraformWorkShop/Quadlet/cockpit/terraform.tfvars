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
          value_sets = [
            {
              name          = "cockpit.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "cockpit.tls.contents.server\\.crt"
              value_ref_key = "cert_pem_chain"
            },
            {
              name          = "cockpit.tls.contents.server\\.key"
              value_ref_key = "key_pem"
            }
          ]
          tfstate = {
            backend = {
              type = "local"
              config = {
                path = "../../TLS/RootCA/terraform.tfstate"
              }
            }
            cert_name = "cockpit.day0"
          }
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
            # kube
            yaml          = "cockpit-aio.yaml"
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
        name   = "cockpit"
        status = "start"
      }
    },
  ]
}
