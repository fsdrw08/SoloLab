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
      name       = "nomad"
      chart      = "../../../HelmWorkShop/helm-charts/charts/nomad"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2-certs"
            name  = "nomad.day1.sololab"
          }
          value_sets = [
            {
              name          = "nomad.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "nomad.secret.tls.contents.server\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "nomad.secret.tls.contents.server\\.key"
              value_ref_key = "private_key"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2-consul"
            name  = "token-nomad_server"
          }
          value_sets = [
            {
              name          = "nomad.secret.others.contents.consul_token\\.json.consul.token"
              value_ref_key = "token"
            }
          ]
        },
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/nomad-aio.yaml"
  },
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    {
      files = [
        {
          template = "./attachments/quadlet.kube"
          # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
          vars = {
            # unit
            Description           = "Nomad is a highly available, distributed, data-center aware cluster and application scheduler designed to support the modern datacenter with support for long-running services, batch jobs, and much more."
            Documentation         = "https://www.nomadproject.io/docs/"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            PodmanArgs = "--tls-verify=false"
            Network    = ""
            # kube
            yaml          = "nomad-aio.yaml"
            KubeDownForce = "false"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPreConsul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://consul.service.consul:8501/v1/catalog/services"
            ExecStartPreVault  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day1.sololab:8200/v1/identity/oidc/.well-known/openid-configuration"
            ExecStartPost      = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && [ -f /var/home/podmgr/.local/share/containers/storage/volumes/nomad-pvc/_data/server/nomad_token ] && podman healthcheck run nomad-agent || echo done \""
            Restart            = "no" #"on-failure"
          }
        },
      ]
      service = {
        name   = "nomad"
        status = "start"
      }
    },
  ]
}

post_process = {
  "New-NomadAnonymousPolicy.sh" = {
    script_path = "./attachments/New-NomadAnonymousPolicy.sh"
    vars = {
      NOMAD_ADDR       = "https://localhost:4646"
      NOMAD_TOKEN_FILE = "/var/home/podmgr/.local/share/containers/storage/volumes/nomad-pvc/_data/server/nomad_token"
      WORKLOAD         = "nomad-agent"
    }
  }
}
