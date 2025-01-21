vm_conn = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name   = "traefik"
    chart  = "../../../HelmWorkShop/helm-charts/charts/traefik"
    values = "./podman-traefik/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-traefik/traefik-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "traefik-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "true"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "traefik-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-traefik/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/traefik_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-traefik/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/traefik-container.service"
        target_service   = "traefik-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/traefik_restart.service"
  }

}
