vm_conn = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube_traefik = {
  ext_vol_dir = "/mnt/data/ci-traefik"
  helm = {
    chart  = "../../../HelmWorkShop/helm-charts/charts/traefik"
    values = "./podman-traefik/values-sololab-ci.yaml"
  }
  yaml_file_dir = "/home/podmgr/.config/containers/systemd"
}

podman_quadlet_traefik = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-traefik/traefik.kube"
        vars = {
          requires           = "var-mnt-data.mount"
          assert_path_exists = "/mnt/data/ci-traefik"
          yaml               = "traefik-aio.yaml"
        }
      }
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "traefik"
    status = "start"
  }
}

podman_kube_jenkins = {
  ext_vol_dir = [
    "/mnt/data/jenkins/home",
    "/mnt/data/jenkins/plugins-loading",
  ]
  helm = {
    chart  = "../../../HelmWorkShop/helm-charts/charts/jenkins-server"
    values = "./podman-jenkins/values-sololab-ci.yaml"
  }
  yaml_file_dir = "/home/podmgr/.config/containers/systemd"
}

podman_quadlet_jenkins = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-jenkins/jenkins.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          requires = ["var-mnt-data.mount"]
          assert_path_exists = [
            "/mnt/data/jenkins/home",
            "/mnt/data/jenkins/plugins-loading"
          ]
          yaml = ["traefik-aio.yaml"]
        }
      }
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "traefik"
    status = "start"
  }
}
