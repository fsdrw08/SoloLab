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
  service_status = "start"
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
}
