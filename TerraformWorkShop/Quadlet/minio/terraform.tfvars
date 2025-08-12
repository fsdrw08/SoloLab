prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_remote = {
  host     = "192.168.255.20"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

podman_kubes = [
  {
    helm = {
      name       = "minio"
      chart      = "../../../HelmWorkShop/helm-charts/charts/minio"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2/certs"
            name  = "minio-api.day1.sololab"
          }
          value_sets = [
            {
              name          = "minio.tls.contents.public\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "minio.tls.contents.private\\.key"
              value_ref_key = "private_key"
            },
            {
              name          = "minio.tls.contents.CAs.sololab\\.crt"
              value_ref_key = "ca"
            }
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/minio-aio.yaml"

}]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "MinIO is a high-performance, S3 compatible object store, open sourced under GNU AGPLv3 license."
            Documentation         = "https://min.io/docs/minio/container/index.html"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "minio-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day1.sololab/v1/identity/oidc/.well-known/openid-configuration"
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && podman healthcheck run minio-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "minio"
        status = "start"
      }
    },
  ]
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_records = [
  {
    zone = "day1.sololab."
    name = "minio-api.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1-fcos.node.consul."
    ]
  },
  {
    zone = "day1.sololab."
    name = "minio-console.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1-fcos.node.consul."
    ]
  },
]
