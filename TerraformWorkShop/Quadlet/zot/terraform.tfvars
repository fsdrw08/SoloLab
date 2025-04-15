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
    tls = {
      value_sets = [
        {
          name          = "zot.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "zot.tls.contents.server\\.crt"
          value_ref_key = "cert_pem"
        },
        {
          name          = "zot.tls.contents.server\\.key"
          value_ref_key = "key_pem"
        }
      ]
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
        Network       = "host"
        Restart       = "on-failure"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "zot-container"
    status = "start"
  }
}
