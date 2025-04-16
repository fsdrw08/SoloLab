prov_vault = {
  address         = "https://vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kube = {
  helm = {
    name       = "minio"
    chart      = "../../../HelmWorkShop/helm-charts/charts/minio"
    value_file = "./podman-minio/values-sololab.yaml"
    tls = {
      value_sets = [
        {
          name          = "minio.tls.contents.public\\.crt"
          value_ref_key = "cert_pem"
        },
        {
          name          = "minio.tls.contents.private\\.key"
          value_ref_key = "key_pem"
        },
        {
          name          = "minio.tls.contents.CAs.sololab\\.crt"
          value_ref_key = "ca"
        }
      ]
      tfstate = {
        backend = {
          type = "local"
          config = {
            path = "../../TLS/RootCA/terraform.tfstate"
          }
        }
        cert_name = "minio"
      }
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/minio-aio.yaml"
}

podman_quadlet = {
  service = {
    name   = "minio-container"
    status = "start"
  }
  files = [
    {
      template = "./podman-minio/minio-container.kube"
      vars = {
        Description   = "MinIO is a high-performance, S3 compatible object store, open sourced under GNU AGPLv3 license."
        Documentation = "https://min.io/docs/minio/container/index.html"
        yaml          = "minio-aio.yaml"
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
  api_key    = "powerdns"
  server_url = "http://pdns-auth.day0.sololab:8081"
}

dns_records = [
  {
    zone = "day0.sololab."
    name = "minio-api.day0.sololab."
    type = "A"
    ttl  = 86400
    records = [
      "192.168.255.10"
    ]
  },
  {
    zone = "day0.sololab."
    name = "minio-console.day0.sololab."
    type = "A"
    ttl  = 86400
    records = [
      "192.168.255.10"
    ]
  },
]
