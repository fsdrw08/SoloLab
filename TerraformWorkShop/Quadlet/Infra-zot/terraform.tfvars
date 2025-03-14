prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "zot"
    chart      = "../../../HelmWorkShop/helm-charts/charts/zot"
    value_file = "./podman-zot/values-sololab.yaml"
    tls_value_sets = {
      name = {
        ca          = "zot.tls.contents.\"ca\\.crt\""
        cert        = "zot.tls.contents.\"server\\.crt\""
        private_key = "zot.tls.contents.\"server\\.key\""
      }
      value_ref = {
        tfstate = {
          backend = {
            type = "local"
            config = {
              path = "../../TLS/RootCA/terraform.tfstate"
            }
          }
          cert_name = "zot"
        }
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/zot-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-zot/zot-container.kube"
      vars = {
        Description   = "OCI-native container image registry, simplified"
        Documentation = "https://zotregistry.dev/latest/admin-guide/admin-configuration/"
        yaml          = "zot-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "zot-container"
    status = "start"
  }
}
