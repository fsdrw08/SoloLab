prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "traefik"
    chart      = "../../../HelmWorkShop/helm-charts/charts/traefik"
    value_file = "./podman-traefik/values-sololab.yaml"
    tls_value_sets = {
      value_ref = {
        tfstate = {
          backend = {
            type = "local"
            config = {
              path = "../../TLS/RootCA/terraform.tfstate"
            }
          }
          cert_name = "traefik"
          data_key = {
            ca          = "zot.tls.contents.\"ca\\.crt\""
            cert        = "zot.tls.contents.\"server\\.crt\""
            private_key = "zot.tls.contents.\"server\\.key\""
          }
        }
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/traefik-aio.yaml"
}

podman_quadlet = {
  service = {
    name   = "traefik-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-traefik/traefik-container.container"
      vars = {
        Description   = "Traefik Proxy"
        Documentation = "https://docs.traefik.io"
        PodmanArgs    = "--tls-verify=false"
        Network       = "host"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
    {
      template = "./podman-traefik/traefik-container.volume"
      vars = {
        VolumeName = "traefik-pvc"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    }
  ]
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "http://pdns-auth.day0.sololab:8081"
}

dns_record = {
  zone = "day0.sololab."
  name = "traefik.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
