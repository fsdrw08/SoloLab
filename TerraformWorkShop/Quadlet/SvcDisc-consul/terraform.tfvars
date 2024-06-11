vm_conn = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name   = "consul"
    chart  = "../../../HelmWorkShop/helm-charts/charts/consul"
    values = "./podman-consul/values-sololab.yaml"
  }
  yaml_file_path = "/home/podmgr/.config/containers/systemd/consul-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-consul/consul-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "consul-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "true"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "consul-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-consul/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/consul-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/consul_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-consul/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/consul-container.service"
        target_service   = "consul-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/consul_restart.service"
  }

}
