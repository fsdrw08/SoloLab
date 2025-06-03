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
  dir = "/home/podmgr/.config/containers/systemd"
  files = [
    {
      template = "../templates/quadlet.kube"
      vars = {
        # unit
        Description           = "Traefik Proxy"
        Documentation         = "https://docs.traefik.io"
        After                 = ""
        Wants                 = ""
        StartLimitIntervalSec = 120
        StartLimitBurst       = 3
        # kube
        yaml          = "traefik-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        # service
        ExecStartPre  = ""
        ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 8-13 -n 1) && podman healthcheck run traefik-proxy\""
        Restart       = "on-failure"
      }
    },
  ]
  service = {
    name   = "traefik"
    status = "start"
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "http://pdns-auth.day0.sololab:8081"
}

dns_records = [
  {
    zone = "day0.sololab."
    name = "traefik.day0.sololab."
    type = "A"
    ttl  = 86400
    records = [
      "192.168.255.10"
    ]
  }
]
