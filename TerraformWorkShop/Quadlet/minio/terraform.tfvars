prov_remote = {
  host     = "192.168.255.10"
  port     = 22
  user     = "podmgr"
  password = "podmgr"
}

prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

podman_kubes = [
  {
    helm = {
      name       = "minio"
      chart      = "../../../HelmWorkShop/helm-charts/charts/minio"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          tfstate = {
            backend = {
              type = "local"
              config = {
                path = "../../TLS/RootCA/terraform.tfstate"
              }
            }
            cert_name = "root"
          }
          value_sets = [
            {
              name          = "minio.secret.tls.contents.CAs.sololab\\.crt"
              value_ref_key = "ca"
            }
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_vault"
            name  = "oidc-provider_sololab"
          }
          value_sets = [
            {
              name          = "minio.config.MINIO_IDENTITY_OPENID_CONFIG_URL"
              value_ref_key = "config_url"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_vault"
            name  = "oidc-client_minio"
          }
          value_sets = [
            {
              name          = "minio.config.MINIO_IDENTITY_OPENID_CLIENT_ID"
              value_ref_key = "client_id"
            },
            {
              name          = "minio.config.MINIO_IDENTITY_OPENID_CLIENT_SECRET"
              value_ref_key = "client_secret"
            },
          ]
        },
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
            StartLimitBurst       = 5
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "minio-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = ""
            # service
            # wait until vault oidc ready
            # ref: https://github.com/vmware-tanzu/pinniped/blob/b8b460f98a35d69a99d66721c631a8c2bd438d2c/hack/prepare-supervisor-on-kind.sh#L502
            ExecStartPre  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://vault.day0.sololab/v1/identity/oidc/.well-known/openid-configuration"
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
