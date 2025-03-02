prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "powerdns"
    chart      = "../../../HelmWorkShop/helm-charts/charts/pdns-auth"
    value_file = "./podman-powerdns/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/powerdns-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-powerdns/powerdns-container.kube"
      vars = {
        yaml          = "powerdns-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "powerdns-container"
    status = "start"
  }
}

post_process = {
  "Enable-DDNSUpdate.sh" = {
    script_path = "./podman-powerdns/Enable-DDNSUpdate.sh"
    vars = {
      PDNS_HOST        = "http://192.168.255.20:8081"
      PDNS_API_KEY     = "powerdns"
      ZONE_NAME        = "day0.sololab."
      ZONE_FQDN        = "day0.sololab."
      TSIG_KEY_NAME    = "dhcp-key"
      TSIG_KEY_CONTENT = "AobsqQd3xT6oYFd51iayOwr/nz883CEndLc7NjCZj8kZ0v6GvWhGPF2etFrGmP7kTaiTBJXBJU5aFHqDycnbFg=="
    }
  }
}

