prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "kea"
    chart      = "../../../HelmWorkShop/helm-charts/charts/kea"
    value_file = "./podman-kea/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/kea-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-kea/kea-container.kube"
      vars = {
        Description   = "Modern, open source DHCPv4 & DHCPv6 server"
        Documentation = "https://readthedocs.org/projects/kea/"
        yaml          = "kea-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "true"
        Restart       = "no" #"on-failure"
        Network       = "host"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "kea-container"
    status = "start"
  }
}

# post_process = {
#   "Enable-DDNSUpdate.sh" = {
#     script_path = "./podman-kea/Enable-DDNSUpdate.sh"
#     vars = {
#       PDNS_HOST        = "http://192.168.255.20:8081"
#       PDNS_API_KEY     = "kea"
#       ZONE_NAME        = "day0.sololab."
#       ZONE_FQDN        = "day0.sololab."
#       TSIG_KEY_NAME    = "dhcp-key"
#       TSIG_KEY_CONTENT = "AobsqQd3xT6oYFd51iayOwr/nz883CEndLc7NjCZj8kZ0v6GvWhGPF2etFrGmP7kTaiTBJXBJU5aFHqDycnbFg=="
#     }
#   }
# }

