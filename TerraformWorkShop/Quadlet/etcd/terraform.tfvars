prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "etcd"
    chart      = "../../../HelmWorkShop/helm-charts/charts/etcd"
    value_file = "./podman-etcd/values-sololab.yaml"
    secrets = {
      value_sets = [
        {
          name          = "etcd.tls.contents.server\\.crt"
          value_ref_key = "cert"
        },
        {
          name          = "etcd.tls.contents.server\\.key"
          value_ref_key = "private_key"
        },
      ]
      tfstate = {
        backend = {
          type = "local"
          config = {
            path = "../../TLS/RootCA/terraform.tfstate"
          }
        }
        cert_name = "etcd-server"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/etcd-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
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
    },
  ]
}
