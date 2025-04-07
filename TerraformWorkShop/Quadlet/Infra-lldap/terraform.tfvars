prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "lldap"
    chart      = "../../../HelmWorkShop/helm-charts/charts/lldap"
    value_file = "./podman-lldap/values-sololab.yaml"
    tls = {
      value_sets = [
        {
          name          = "lldap.ssl.contents.\"cert\\.pem\""
          value_ref_key = "cert_pem"
        },
        {
          name          = "lldap.ssl.contents.\"key\\.pem\""
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
        cert_name = "lldap"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/lldap-aio.yaml"
}

podman_quadlet = {
  service = {
    name   = "lldap-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-lldap/lldap-container.kube"
      vars = {
        Description   = "lldap Proxy"
        Documentation = "https://docs.lldap.io"
        yaml          = "lldap-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        Restart       = "on-failure"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
    {
      template = "./podman-lldap/lldap-container.volume"
      vars = {
        VolumeName = "lldap-pvc"
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
  name = "lldap.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
