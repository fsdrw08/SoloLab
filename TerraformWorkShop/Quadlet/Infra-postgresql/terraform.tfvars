prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "tfbackend-pg"
    chart      = "../../../HelmWorkShop/helm-charts/charts/postgresql"
    value_file = "./podman-postgresql/values-sololab.yaml"
    value_sets = [
      {
        name         = "fullnameOverride"
        value_string = "tfbackend-pg"
      }
    ]
    tls = {
      value_sets = [
        {
          name          = "postgresql.ssl.contents.\"tls\\.crt\""
          value_ref_key = "cert_pem"
        },
        {
          name          = "postgresql.ssl.contents.\"tls\\.key\""
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
        cert_name = "tfbackend-pg"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/tfbackend-pg-aio.yaml"
}

podman_quadlet = {
  service = {
    name   = "tfbackend-pg-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-postgresql/tfbackend-pg-container.kube"
      # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
      vars = {
        Description   = "PostgreSQL is a powerful, open source object-relational database system"
        Documentation = "https://www.postgresql.org/"
        yaml          = "tfbackend-pg-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        Restart       = "on-failure"
      }
      dir = "/home/podmgr/.config/containers/systemd"
    },
  ]
}

prov_pdns = {
  api_key        = "powerdns"
  server_url     = "https://pdns-auth.day0.sololab"
  insecure_https = true
}

dns_record = {
  zone = "day0.sololab."
  name = "tfbackend-pg.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
