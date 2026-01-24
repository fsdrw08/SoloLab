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
      name       = "consul-template"
      chart      = "../../../HelmWorkShop/helm-charts/charts/consul-template"
      value_file = "./attachments/values-sololab.yaml"
      value_refers = [
        {
          vault_kvv2 = {
            mount = "kvv2_certs"
            name  = "root"
          }
          value_sets = [
            {
              name          = "consulTemplate.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            }
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_consul"
            name  = "token-consul_client"
          }
          value_sets = [
            {
              name          = "consulTemplate.configFiles.main.consul.token"
              value_ref_key = "token"
            },
          ]
        },
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/consul-template-aio.yaml"
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
            Description           = "Template rendering, notifier, and supervisor for @hashicorp Consul and Vault data."
            Documentation         = "https://github.com/hashicorp/consul-template/tree/main"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "consul-template-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://consul.service.consul:8501/v1/catalog/services"
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        }
      ]
      service = {
        name   = "consul-template"
        status = "start"
      }
    },
  ]
}

# post_process = {
#   "Enable-DNSAnonymousAccess.sh" = {
#     script_path = "./attachments/Enable-DNSAnonymousAccess.sh"
#     vars = {
#       CONSUL_HTTP_ADDR = "https://localhost:8501"
#       INIT_TOKEN       = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
#     }
#   }
# }
