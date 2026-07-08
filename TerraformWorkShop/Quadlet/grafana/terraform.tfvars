prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_remote = {
  host = "192.168.255.20"
  port = 22
  credential = {
    "user" = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "vm-day2"
        key   = "rootless_username"
      }
    }
    "password" = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "vm-day2"
        key   = "rootless_password"
      }
    }
  }
}

podman_kubes = [
  # {
  #   helm = {
  #     name       = "grafana-database"
  #     chart      = "../../../HelmWorkShop/helm-charts/charts/postgresql"
  #     value_file = "./attachments-postgresql/values-sololab.yaml"
  #     value_sets = [
  #       {
  #         name            = "fullnameOverride"
  #         value_plaintext = "grafana-database"
  #       }
  #     ]
  #   }
  #   manifest_dest_path = "/home/podmgr/.config/containers/systemd/grafana-pg-aio.yaml"
  # },
  {
    helm = {
      name       = "grafana"
      chart      = "../../../HelmWorkShop/helm-charts/charts/grafana"
      value_file = "./attachments/values-sololab.yaml"
      value_refers = [
        {
          vault_kvv2 = {
            mount = "kvv2_certs"
            name  = "sololab_root"
          }
          value_sets = [
            {
              name          = "grafana.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_others"
            name  = "app-grafana"
          }
          value_sets = [
            {
              name          = "grafana.configFiles.grafana.security.admin_user"
              value_ref_key = "admin_username"
            },
            {
              name          = "grafana.secret.others.contents.admin_password"
              value_ref_key = "admin_password"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_vault"
            name  = "oidc-provider_sololab"
          }
          value_sets = [
            {
              name          = "grafana.configFiles.grafana.auth\\.generic_oauth.auth_url"
              value_ref_key = "authorization_endpoint"
            },
            {
              name          = "grafana.configFiles.grafana.auth\\.generic_oauth.api_url"
              value_ref_key = "userinfo_endpoint"
            },
            {
              name          = "grafana.configFiles.grafana.auth\\.generic_oauth.token_url"
              value_ref_key = "token_endpoint"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_vault"
            name  = "oidc-client_grafana"
          }
          value_sets = [
            # https://github.com/ordiri/ordiri/blob/e18120c4c00fa45f771ea01a39092d6790f16de8/manifests/platform/monitoring/base/kustomization.yaml#L132
            # https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/generic-oauth/#steps
            {
              name          = "grafana.secret.others.contents.oauth_client_id"
              value_ref_key = "client_id"
            },
            {
              name          = "grafana.secret.others.contents.oauth_client_secret"
              value_ref_key = "client_secret"
            },
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/grafana-aio.yaml"
  }
]

podman_quadlet = {
  dir = "/home/podmgr/.config/containers/systemd"
  units = [
    # {
    #   files = [
    #     {
    #       template = "../templates/quadlet.kube"
    #       vars = {
    #         # unit
    #         Description           = "Grafana PostgreSQL backend"
    #         Documentation         = "https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#database"
    #         After                 = ""
    #         Wants                 = ""
    #         StartLimitIntervalSec = 120
    #         StartLimitBurst       = 3
    #         Before                = "umount.target"
    #         Conflicts             = "umount.target"
    #         # kube
    #         yaml          = "grafana-pg-aio.yaml"
    #         PodmanArgs    = "--tls-verify=false"
    #         KubeDownForce = "false"
    #         Network       = ""
    #         # service
    #         ExecStartPre  = ""
    #         ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && podman healthcheck run grafana-database-postgresql\""
    #         Restart       = "on-failure"
    #       }
    #     }
    #   ]
    #   service = {
    #     name   = "grafana-database"
    #     status = "start"
    #   }
    # },
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "Grafana instance"
            Documentation         = "https://docs.grafana.org"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # podman
            Network    = ""
            PodmanArgs = "--tls-verify=false"
            # kube
            KubeDownForce = "false"
            yaml          = "grafana-aio.yaml"
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day1.sololab/v1/identity/oidc/.well-known/openid-configuration"
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 20-30 -n 1) && podman healthcheck run grafana-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "grafana"
        status = "start"
      }
    },
  ]
}
