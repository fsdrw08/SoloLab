prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "coredns"
      chart      = "../../../HelmWorkShop/helm-charts/charts/coredns"
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
            cert_name = "root"
          }
          value_sets = [
            {
              name          = "coredns.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/coredns-aio.yaml"
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
            Description           = "CoreDNS"
            Documentation         = "https://coredns.io/manual/toc/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "coredns-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "true"
            Network       = "host"
            # service
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure"
          }
          dir = "/home/podmgr/.config/containers/systemd"
        }
      ]
      service = {
        name   = "coredns"
        status = "start"
      }
    },
  ]
}
