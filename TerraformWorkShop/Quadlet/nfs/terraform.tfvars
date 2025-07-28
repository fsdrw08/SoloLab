prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "core"
  password = "P@ssw0rd"
  sudo     = true
}

podman_kubes = [
  {
    helm = {
      name       = "nfs"
      chart      = "../../../HelmWorkShop/helm-charts/charts/nfs-ganesha"
      value_file = "./podman-nfs/values-sololab.yaml"
    }
    manifest_dest_path = "/etc/containers/systemd/nfs-aio.yaml"
  }
]

podman_quadlet = {
  dir = "/etc/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
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
            yaml          = "nfs-aio.yaml"
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
        name   = "nfs"
        status = "start"
      }
    }
  ]
}

prov_pdns = {
  api_key        = "powerdns"
  server_url     = "https://pdns-auth.day0.sololab"
  insecure_https = true
}

dns_record = {
  zone = "day0.sololab."
  name = "nfs.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
