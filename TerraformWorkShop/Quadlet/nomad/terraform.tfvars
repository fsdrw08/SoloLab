prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

podman_kube = {
  helm = {
    name       = "nomad"
    chart      = "../../../HelmWorkShop/helm-charts/charts/nomad"
    value_file = "./podman-nomad/values-sololab.yaml"
    # value_sets = [
    #   {
    #     name         = "nomad.configFiles.main.advertise.http"
    #     value_string = "192.168.255.10"
    #   },
    #   {
    #     name         = "nomad.configFiles.main.advertise.rpc"
    #     value_string = "192.168.255.10"
    #   },
    #   {
    #     name         = "nomad.configFiles.main.advertise.serf"
    #     value_string = "192.168.255.10"
    #   },
    # ]
    tls = {
      tfstate = {
        backend = {
          type = "local"
          config = {
            path = "../../TLS/RootCA/terraform.tfstate"
          }
        }
        cert_name = "nomad"
      }
      value_sets = [
        {
          name          = "nomad.tls.contents.ca\\.crt"
          value_ref_key = "ca"
        },
        {
          name          = "nomad.tls.contents.server\\.crt"
          value_ref_key = "cert_pem"
        },
        {
          name          = "nomad.tls.contents.server\\.key"
          value_ref_key = "key_pem"
        },
      ]
    }
  }
  manifest_dest_path = "/home/podmgr/.config/containers/systemd/nomad-aio.yaml"
}

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  files = [
    {
      template = "../templates/quadlet.kube"
      # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
      vars = {
        # unit
        Description           = "Nomad is a highly available, distributed, data-center aware cluster and application scheduler designed to support the modern datacenter with support for long-running services, batch jobs, and much more."
        Documentation         = "https://www.nomadproject.io/docs/"
        After                 = ""
        Wants                 = ""
        StartLimitIntervalSec = 5
        StartLimitBurst       = 3
        # kube
        yaml          = "nomad-aio.yaml"
        PodmanArgs    = "--tls-verify=false"
        KubeDownForce = "false"
        Network       = "host"
        # service
        # wait until vault oidc ready
        # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
        ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab:8200/v1/identity/oidc/.well-known/openid-configuration"
        ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 15-20 -n 1) && podman healthcheck run nomad-agent\""
        Restart       = "on-failure"
      }
    },
  ]
  service = {
    name   = "nomad"
    status = "start"
  }
}

post_process = {
  "New-NomadAnonymousPolicy.sh" = {
    script_path = "./podman-nomad/New-NomadAnonymousPolicy.sh"
    vars = {
      NOMAD_ADDR       = "https://192.168.255.10:4646"
      NOMAD_TOKEN_FILE = "/var/home/podmgr/.local/share/containers/storage/volumes/nomad-pvc/_data/server/nomad_token"
    }
  }
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_record = {
  zone = "day0.sololab."
  name = "nomad.day0.sololab."
  type = "A"
  ttl  = 86400
  records = [
    "192.168.255.10"
  ]
}
