vm_conn = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    chart  = "../../../HelmWorkShop/helm-charts/charts/consul"
    values = "./podman-consul/values-sololab.yaml"
  }
  yaml_file_dir = "/home/podmgr/.config/containers/systemd"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-consul/consul.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "consul-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "false"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "consul"
    status = "start"
  }
}
