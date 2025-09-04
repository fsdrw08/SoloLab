prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "core"
  password = "P@ssw0rd"
  sudo     = false
}

podman_kubes = [
  {
    helm = {
      name       = "nfs-ganesha"
      chart      = "../../../HelmWorkShop/helm-charts/charts/nfs-ganesha"
      value_file = "./attachments/values-sololab.yaml"
    }
    manifest_dest_path = "/var/home/core/.config/containers/systemd/nfs-ganesha-aio.yaml"
  }
]

podman_quadlet = {
  # dir = "/var/home/core/.config/containers/systemd"
  dir = "/var/home/core/.local/etc/containers/systemd"
  units = [
    {
      files = [
        {
          # template = "../templates/quadlet.kube"
          template = "./attachments/nfs-ganesha.container"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            # unit
            Description           = "NFS-Ganesha is an NFSv3,v4,v4.1 fileserver that runs in user mode on most UNIX/Linux systems"
            Documentation         = "https://github.com/nfs-ganesha/nfs-ganesha/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "nfs-ganesha-aio.yaml"
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
        name   = "nfs-ganesha"
        status = "start"
      }
    }
  ]
}
