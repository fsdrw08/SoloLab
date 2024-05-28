vm_conn = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    chart  = "../../../HelmWorkShop/helm-charts/charts/vault"
    values = "./podman-vault/values-sololab.yaml"
  }
  yaml_file_dir = "/home/podmgr/.config/containers/systemd"
}

podman_quadlet = {
  quadlet = {
    file_contents = [
      {
        file_source = "./podman-vault/vault.kube"
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = {
          yaml       = "vault-aio.yaml"
          PodmanArgs = "--tls-verify=false"
        }
      },
      # {
      #   file_source = "./podman-vault/vault.image"
      #   # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
      #   vars = {
      #     Image     = "zot.mgmt.sololab/hashicorp/vault:1.16.2"
      #     TLSVerify = "false"
      #   }
      # }
    ]
    file_path_dir = "/home/podmgr/.config/containers/systemd"
  }
  service = {
    name   = "vault"
    status = "start"
  }
}
