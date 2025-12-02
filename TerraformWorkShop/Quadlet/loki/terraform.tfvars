prov_vault = {
  address         = "https://vault.day0.sololab"
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
      name       = "loki"
      chart      = "../../../HelmWorkShop/helm-charts/charts/loki"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2_minio"
            name  = "loki"
          }
          # https://github.com/ordiri/ordiri/blob/e18120c4c00fa45f771ea01a39092d6790f16de8/manifests/platform/monitoring/base/kustomization.yaml#L132
          # https://grafana.com/docs/grafana/v3.5.x/setup-grafana/configure-security/configure-authentication/generic-oauth/#steps
          value_sets = [
            {
              name          = "loki.config.storage_config.object_store.s3.access_key_id"
              value_ref_key = "access_key"
            },
            {
              name          = "loki.config.storage_config.object_store.s3.secret_access_key"
              value_ref_key = "secret_key"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_certs"
            name  = "sololab_root"
          }
          value_sets = [
            {
              name          = "loki.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
          ]
        }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/loki-aio.yaml"
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
            Description           = "Loki service"
            Documentation         = "https://grafana.com/docs/loki/v3.5.x/"
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
            yaml          = "loki-aio.yaml"
            # service
            ExecStartPre = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://minio-api.day0.sololab/minio/health/live"
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            # ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 80-90 -n 1) && podman healthcheck run loki-server \"" # || sleep $(shuf -i 30-35 -n 1) && podman healthcheck run loki-server \""
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "loki"
        status = "start"
      }
    },
  ]
}
