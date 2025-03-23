prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "cockpit"
    chart      = "../../../HelmWorkShop/helm-charts/charts/cockpit"
    value_file = "./podman-cockpit/values-sololab.yaml"
    tls_value_sets = {
      tfstate = {
        backend = {
          type = "local"
          config = {
            path = "../../TLS/RootCA/terraform.tfstate"
          }
        }
        cert_name = "cockpit"
        data_key = {
          ca          = "cockpit.tls.contents.\"ca\\.crt\""
          cert        = "cockpit.tls.contents.\"server\\.crt\""
          private_key = "cockpit.tls.contents.\"server\\.key\""
        }
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/cockpit-aio.yaml"
}

podman_quadlet = {
  files = [
    {
      template = "./podman-cockpit/cockpit-container.kube"
      vars = {
        Description   = "Cockpit is a web-based graphical interface for servers."
        Documentation = "https://cockpit-project.org/guide/latest/"
        yaml          = "cockpit-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
  service = {
    name   = "cockpit-container"
    status = "start"
  }
}

prov_pdns = {
  api_key        = "powerdns"
  server_url     = "https://pdns-auth.day0.sololab"
  insecure_https = true
}

dns_record = {
  zone = "day0.sololab."
  name = "cockpit.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
