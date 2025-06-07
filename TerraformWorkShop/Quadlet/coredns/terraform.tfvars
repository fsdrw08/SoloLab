prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "coredns"
    chart      = "../../../HelmWorkShop/helm-charts/charts/coredns"
    value_file = "./podman-coredns/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/coredns-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "./podman-coredns/coredns-container.kube"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            yaml          = "coredns-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "true"
            Network       = "pasta"
          }
          dir = "/home/podmgr/.config/containers/systemd"
        }
      ]
      service = {
        name   = "coredns-container"
        status = "start"
      }
    },
  ]
}
