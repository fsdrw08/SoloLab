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

podman_kubes = [
  {
    helm = {
      name       = "redis-insight"
      chart      = "../../../HelmWorkShop/helm-charts/charts/redis-insight"
      value_file = "./podman-redis-insight/values-sololab.yaml"
      value_refers = [
        {
          vault_kvv2 = {
            mount = "kvv2_certs"
            name  = "redis-insight.day1.sololab"
          }
          value_sets = [
            {
              name          = "redisInsight.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "redisInsight.tls.contents.server\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "redisInsight.tls.contents.server\\.key"
              value_ref_key = "private_key"
            },
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/redis-insight-aio.yaml"
  },
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            # unit
            Description           = "Redis GUI by Redis"
            Documentation         = "https://redis.io/docs/latest/operate/redisinsight/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "redis-insight-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "redis-insight"
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
    name = "redis-insight.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "redis-insight.service.consul."
    ]
  }
]
