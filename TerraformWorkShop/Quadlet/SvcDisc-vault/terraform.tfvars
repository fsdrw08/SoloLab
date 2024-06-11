vm_conn = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name   = "vault"
    chart  = "../../../HelmWorkShop/helm-charts/charts/vault"
    values = "./podman-vault/values-sololab.yaml"
  }
  yaml_file_path = "/home/podmgr/.config/containers/systemd/vault-aio.yaml"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-vault/vault-container.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml          = "vault-aio.yaml"
          PodmanArgs    = "--tls-verify=false"
          KubeDownForce = "false"
        }
      },
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "vault-container"
    status = "start"
  }
}

container_restart = {
  systemd_path_unit = {
    content = {
      templatefile = "./podman-vault/restart.path"
      vars = {
        PathModified = "/home/podmgr/.config/containers/systemd/vault-aio.yaml"
      }
    }
    path = "/home/podmgr/.config/systemd/user/vault_restart.path"
  }
  systemd_service_unit = {
    content = {
      templatefile = "./podman-vault/restart.service"
      vars = {
        AssertPathExists = "/run/user/1001/systemd/generator/vault-container.service"
        target_service   = "vault-container.service"
      }
    }
    path = "/home/podmgr/.config/systemd/user/vault_restart.service"
  }

}
