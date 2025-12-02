prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

podman_kube = {
  helm = {
    name       = "traefik"
    chart      = "../../../HelmWorkShop/helm-charts/charts/traefik"
    value_file = "./podman-traefik/values-sololab.yaml"
    tls_value_sets = {
      value_ref = {
        vault_kvv2 = {
          mount = "kvv2_certs"
          name  = "traefik.day1.sololab"
        }
      }
      value_sets = [
        {
          name          = "traefik.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "traefik.tls.contents.dashboard\\.crt"
          value_ref_key = "cert"
        },
        {
          name          = "traefik.tls.contents.dashboard\\.key"
          value_ref_key = "private_key"
        },
      ]
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
        Network       = "podman-default-kube-network"
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
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "traefik.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
