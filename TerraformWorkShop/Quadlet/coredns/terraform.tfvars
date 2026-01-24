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
      value_refers = [
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
              name          = "coredns.secret.tls.contents.ca\\.crt"
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
            Network       = ""
            # service
            # start after etcd is ready
            ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://192.168.255.10:2379/health"
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
