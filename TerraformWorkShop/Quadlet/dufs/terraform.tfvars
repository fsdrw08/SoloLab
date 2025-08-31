prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "dufs"
      chart      = "../../../HelmWorkShop/helm-charts/charts/dufs"
      value_file = "./attachments/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/dufs-aio.yaml"
  },
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
            Description           = "A file server that supports static serving, uploading, searching, accessing control, webdav..."
            Documentation         = "https://github.com/sigoden/dufs"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "dufs-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "dufs"
        status = "start"
      }
    },
  ]
}

prov_etcd = {
  endpoints = "https://etcd-0.day0.sololab:2379"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

dns_records = [
  {
    hostname = "dufs.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  }
]

