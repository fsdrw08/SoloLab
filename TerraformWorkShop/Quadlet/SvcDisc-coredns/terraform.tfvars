prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name   = "coredns"
    chart  = "../../../HelmWorkShop/helm-charts/charts/coredns"
    values = "./podman-coredns/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/coredns-aio.yaml"
}

podman_quadlet = {
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
}

container_restart = {
  systemd_unit_files = [
    {
      content = {
        templatefile = "./podman-coredns/restart.path"
        vars = {
          PathModified = "/home/podmgr/.config/containers/systemd/coredns-aio.yaml"
        }
      }
      path = "/home/podmgr/.config/systemd/user/coredns_restart.path"
    },
    {
      content = {
        templatefile = "./podman-coredns/restart.service"
        vars = {
          AssertPathExists = "/run/user/1001/systemd/generator/coredns-container.service"
          target_service   = "coredns-container.service"
        }
      }
      path = "/home/podmgr/.config/systemd/user/coredns_restart.service"
    }
  ]

  systemd_unit_name = "coredns_restart"
}
