vm_conn = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name   = "ceph"
    chart  = "../../../HelmWorkShop/helm-charts/charts/ceph"
    values = "./podman-ceph/values.yaml"
    # set = [
    #   {
    #     name  = "ceph.config.global.mon_host"
    #     value = "192.168.255.20"
    #   }
    # ]
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/ceph-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-ceph/ceph-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "ceph-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "true"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "ceph-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-ceph/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/ceph-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/ceph_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-ceph/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/ceph-container.service"
        target_service   = "ceph-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/ceph_restart.service"
  }

}
