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
      value_refers = [
        {
          vault_kvv2 = {
            mount = "kvv2_others"
            name  = "app-dufs"
          }
          value_sets = [
            {
              name          = "dufs.config.auth[0]"
              value_ref_key = "dir_public"
            },
            {
              name          = "dufs.config.auth[1]"
              value_ref_key = "dir_root"
            },
            {
              name          = "dufs.config.auth[2]"
              value_ref_key = "dir_private"
            },
            {
              name          = "dufs.config.auth[3]"
              value_ref_key = "dir_webdav"
            },
          ]
        },
      ]
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
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "dufs-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
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
