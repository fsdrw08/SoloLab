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

podman_kubes = [
  {
    helm = {
      name       = "consul"
      chart      = "../../../HelmWorkShop/helm-charts/charts/consul"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2-certs"
            name  = "consul.day1.sololab"
          }
          value_sets = [
            {
              name          = "consul.configFiles.main.auto_config.authorization.static.oidc_discovery_ca_cert"
              value_ref_key = "ca"
            },
            {
              name          = "consul.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "consul.tls.contents.server\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "consul.tls.contents.server\\.key"
              value_ref_key = "private_key"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2-consul"
            name  = "key-gossip_encryption"
          }
          value_sets = [
            {
              name          = "consul.configFiles.main.encrypt"
              value_ref_key = "key"
            },
          ]
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
            StartLimitBurst       = 5
            # kube
            yaml          = "consul-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = "/bin/bash -c \"curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day1.sololab:8200/v1/identity/oidc/.well-known/openid-configuration\""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 8-12 -n 1) && podman healthcheck run consul-agent\""
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

post_process = {
  "Enable-DNSAnonymousAccess.sh" = {
    script_path = "./attachments/Enable-DNSAnonymousAccess.sh"
    vars = {
      CONSUL_HTTP_ADDR = "https://192.168.255.20:8501"
      INIT_TOKEN       = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_records = [
  {
    zone = "day1.sololab."
    name = "consul.day1.sololab."
    type = "A"
    ttl  = 86400
    records = [
      "192.168.255.20"
    ]
  }
]
