prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

podman_kube = {
  helm = {
    name       = "whoami"
    chart      = "../../../HelmWorkShop/helm-charts/charts/whoami"
    value_file = "./podman-whoami/values-sololab.yaml"
    value_sets = [
      {
        name         = "whoami.configFiles.main.advertise.http"
        value_string = "192.168.255.20"
      },
      {
        name         = "whoami.configFiles.main.advertise.rpc"
        value_string = "192.168.255.20"
      },
      {
        name         = "whoami.configFiles.main.advertise.serf"
        value_string = "192.168.255.20"
      },
    ]
    tls_value_sets = {
      value_ref = {
        vault_kvv2 = {
          mount = "kvv2/certs"
          name  = "whoami.day1.sololab"
        }
      }
      value_sets = [
        {
          name          = "whoami.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "whoami.tls.contents.server\\.crt"
          value_ref_key = "cert"
        },
        {
          name          = "whoami.tls.contents.server\\.key"
          value_ref_key = "private_key"
        },
      ]
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/whoami-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "./podman-whoami/whoami-container.kube"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            Description   = "Tiny Go webserver that prints OS information and HTTP request to output."
            Documentation = "https://github.com/traefik/whoami, https://hub.docker.com/r/traefik/whoami"
            yaml          = "whoami-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            ExecStartPre  = "sleep 3"
            KubeDownForce = "false"
          }
          dir = "/home/podmgr/.config/containers/systemd"
        },
      ]
      service = {
        name   = "whoami-container"
        status = "start"
      }
    },
  ]
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns.day0.sololab"
}

dns_record = {
  zone = "day1.sololab."
  name = "whoami.day1.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.20"
  ]
}
