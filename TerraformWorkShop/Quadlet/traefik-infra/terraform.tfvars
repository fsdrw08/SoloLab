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
    tls = {
      value_sets = [
        {
          name          = "traefik.tls.contents.\"ca\\.crt\""
          value_ref_key = "ca"
        },
        {
          name          = "traefik.tls.contents.\"day0\\.crt\""
          value_ref_key = "cert_pem"
        },
        {
          name          = "traefik.tls.contents.\"day0\\.key\""
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
        cert_name = "traefik.day0"
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
      template = "./podman-traefik/traefik-container.kube"
      vars = {
        Description   = "Traefik Proxy"
        Documentation = "https://docs.traefik.io"
        yaml          = "traefik-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        Restart       = "on-failure"
        ExecStartPost = "/bin/bash -c \"sleep 5 && podman healthcheck run traefik-proxy\""
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
