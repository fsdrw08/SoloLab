prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "powerdns"
    chart      = "../../../HelmWorkShop/helm-charts/charts/pdns"
    value_file = "./podman-powerdns/values-sololab.yaml"
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/powerdns-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-powerdns/powerdns-container.kube"
      vars = {
        Description   = "The PowerDNS Authoritative Server is a versatile nameserver which supports a large number of backends."
        Documentation = "https://doc.powerdns.com/authoritative/index.html"
        yaml          = "powerdns-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        ExecStartPost = "/bin/bash -c \"sleep 5 && podman healthcheck run powerdns-auth\""
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
      PDNS_HOST        = "http://192.168.255.10:8081"
      PDNS_API_KEY     = "powerdns"
      ZONE_NAME        = "day0.sololab."
      ZONE_FQDN        = "day0.sololab."
      TSIG_KEY_NAME    = "dhcp-key"
      TSIG_KEY_CONTENT = "AobsqQd3xT6oYFd51iayOwr/nz883CEndLc7NjCZj8kZ0v6GvWhGPF2etFrGmP7kTaiTBJXBJU5aFHqDycnbFg=="
    }
  }
}

