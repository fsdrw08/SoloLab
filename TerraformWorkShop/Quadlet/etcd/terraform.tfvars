prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "etcd"
      chart      = "../../../HelmWorkShop/helm-charts/charts/etcd"
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
            cert_name = "etcd-server.day0"
          }
          value_sets = [
            {
              name          = "etcd.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "etcd.secret.tls.contents.server\\.crt"
              value_ref_key = "cert_pem_chain"
            },
            {
              name          = "etcd.secret.tls.contents.server\\.key"
              value_ref_key = "key_pem"
            },
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/etcd-aio.yaml"
  }
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            # unit
            Description           = "etcd key-value store"
            Documentation         = "https://etcd.io/docs/v3.6/op-guide/configuration/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "etcd-aio.yaml"
            KubeDownForce = "false"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = ""
            # service
            ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 8-13 -n 1) && podman healthcheck run etcd-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "etcd"
        status = "start"
      }
    },
  ]
}

post_process = {
  "Enable-UserAuth.sh" = {
    script_path = "./attachments/Enable-UserAuth.sh"
    vars = {
      ETCD_ENDPOINT    = "https://localhost:2379"
      ROOT_USERNAME    = "root"
      ROOT_PASSWORD    = "P@ssw0rd"
      MONITOR_USERNAME = "monitor"
      MONITOR_PASSWORD = "monitor"
    }
  }
}
