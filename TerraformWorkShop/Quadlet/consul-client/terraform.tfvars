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
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2-certs"
            name  = "root"
          }
          value_sets = [
            {
              name          = "consul.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2-consul"
            name  = "token-consul_client"
          }
          value_sets = [
            {
              name          = "consul.configFiles.main.acl.tokens.default"
              value_ref_key = "token"
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
            ExecStartPre = "/bin/bash -c \"curl -fLsSk --retry-all-errors --retry 20 --retry-delay 30 https://consul.service.consul/v1/status/leader\""
            # ExecStartPre  = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && podman healthcheck run consul-agent\""
            Restart       = "on-failure"
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
