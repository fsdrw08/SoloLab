prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

certs_ref = {
  tfstate = {
    backend = "local"
    config = {
      path = "../../TLS/RootCA/terraform.tfstate"
    }
    entity = "etcd-server"
  }
  config_node = {
    cert = "etcd.tls.contents.\"server\\.crt\""
    key  = "etcd.tls.contents.\"server\\.key\""
  }
}

podman_kube = {
  helm = {
    name   = "etcd"
    chart  = "../../../HelmWorkShop/helm-charts/charts/etcd"
    values = "./podman-etcd/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/etcd-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-etcd/etcd-container.kube"
      # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
      vars = {
        yaml          = "etcd-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
  ]
  service = {
    name   = "etcd-container"
    status = "start"
  }
}
