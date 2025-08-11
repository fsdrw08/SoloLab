prov_remote = {
  host     = "192.168.255.10"
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

podman_kubes = [
  {
    helm = {
      name       = "consul"
      chart      = "../../../HelmWorkShop/helm-charts/charts/consul"
      value_file = "./podman-consul/values-sololab.yaml"
      tls = [
        {
          value_sets = [
            {
              name          = "consul.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
          ]
          vault_kvv2 = {
            mount = "kvv2/certs"
            name  = "root"
          }
        },
        {
          value_sets = [
            {
              name          = "consul.configFiles.main.acl.tokens.default"
              value_ref_key = "token"
            },
          ]
          vault_kvv2 = {
            mount = "kvv2/consul"
            name  = "token-consul_client"
          }
        },
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/consul-aio.yaml"
  }
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "Consul is a multi-networking tool that offers a fully-featured service mesh solution."
            Documentation         = "https://developer.hashicorp.com/consul/docs"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            # kube
            yaml          = "consul-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            # ExecStartPre  = "/bin/bash -c \"curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab:8200/v1/identity/oidc/.well-known/openid-configuration\""
            # ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && podman healthcheck run consul-agent\""
            ExecStartPre  = ""
            ExecStartPost = ""
            Restart       = ""
          }
        }
      ]
      service = {
        name   = "consul"
        status = "start"
      }
    },
  ]
}

# post_process = {
#   "Enable-DNSAnonymousAccess.sh" = {
#     script_path = "./podman-consul/Enable-DNSAnonymousAccess.sh"
#     vars = {
#       CONSUL_HTTP_ADDR = "https://consul.day0.sololab:8501"
#       INIT_TOKEN       = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
#     }
#   }
# }

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_records = [
  # {
  #   zone = "day1.sololab."
  #   name = "consul-client.day1.sololab."
  #   type = "CNAME"
  #   ttl  = 86400
  #   records = [
  #     "day1.node.consul."
  #   ]
  # },
  {
    zone = "day0.sololab."
    name = "consul-client.day0.sololab."
    type = "A"
    ttl  = 86400
    records = [
      "192.168.255.10"
    ]
  }
]
