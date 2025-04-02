prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "core"
  password = "P@ssw0rd"
}

podman_kube = {
  helm = {
    name       = "nfs"
    chart      = "../../../HelmWorkShop/helm-charts/charts/nfs-ganesha"
    value_file = "./podman-nfs/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/nfs-aio.yaml"
}

podman_quadlet = {
  service = {
    name   = "nfs-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-nfs/nfs-container.kube"
      # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
      vars = {
        Description   = "NFS-Ganesha is an NFSv3,v4,v4.1 fileserver that runs in user mode on most UNIX/Linux systems"
        Documentation = "https://github.com/nfs-ganesha/nfs-ganesha/"
        yaml          = "nfs-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        Restart       = "on-failure"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
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
