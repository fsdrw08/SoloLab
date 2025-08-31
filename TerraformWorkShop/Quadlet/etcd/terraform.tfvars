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
          value_sets = [
            {
              name          = "etcd.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "etcd.tls.contents.server\\.crt"
              value_ref_key = "cert_pem_chain"
            },
            {
              name          = "etcd.tls.contents.server\\.key"
              value_ref_key = "key_pem"
            },
          ]
          tfstate = {
            backend = {
              type = "local"
              config = {
                path = "../../TLS/RootCA/terraform.tfstate"
              }
            }
            cert_name = "etcd-server"
          }
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
            # kube
            yaml          = "etcd-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
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
  "Add-EtcdUser.sh" = {
    script_path = "./attachments/Add-EtcdUser.sh"
    vars = {
      CONTAINER_NAME = "etcd-server"
      ENDPOINTS      = "unix://localhost:0"
      ROOT_PASSWORD  = "P@ssw0rd"
    }
  }
}
