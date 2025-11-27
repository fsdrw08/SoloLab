prov_vault = {
  address         = "https://vault.day1.sololab"
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
      name       = "prometheus"
      chart      = "../../../HelmWorkShop/helm-charts/charts/prometheus"
      value_file = "./attachments-prometheus/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2_certs"
            name  = "sololab_root"
          }
          value_sets = [
            {
              name          = "prometheus.secret.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_vault_token"
            name  = "prometheus-metrics"
          }
          value_sets = [
            {
              name          = "prometheus.secret.others.contents.vault-token"
              value_ref_key = "token"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2_consul"
            name  = "token-prometheus"
          }
          value_sets = [
            {
              name          = "prometheus.secret.others.contents.consul-token"
              value_ref_key = "token"
            },
          ]
        },
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/prometheus-aio.yaml"
  },
  {
    helm = {
      name       = "prometheus-blackbox-exporter"
      chart      = "../../../HelmWorkShop/helm-charts/charts/prometheus-blackbox-exporter"
      value_file = "./attachments-blackbox-exporter/values-sololab.yaml"
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/prometheus-blackbox-exporter-aio.yaml"
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
            Description           = "Prometheus is an open source monitoring and alerting system"
            Documentation         = "https://prometheus.io/docs/prometheus"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "prometheus-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre = ""
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            # ExecStartPost = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 10-15 -n 1) && podman healthcheck run prometheus-server\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "prometheus"
        status = "start"
      }
    },
    {
      files = [
        {
          template = "../templates/quadlet.kube"
          vars = {
            # unit
            Description           = "The blackbox exporter allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP, ICMP and gRPC"
            Documentation         = "https://github.com/prometheus/blackbox_exporter/tree/master"
            After                 = ""
            Wants                 = ""
            StartLimitIntervalSec = 120
            StartLimitBurst       = 3
            Before                = "umount.target"
            Conflicts             = "umount.target"
            # kube
            yaml          = "prometheus-blackbox-exporter-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre = ""
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            # ExecStartPost = ""
            ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 10-15 -n 1) && podman healthcheck run prometheus-blackbox-exporter-workload\""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "prometheus-blackbox-exporter"
        status = "start"
      }
    },
  ]
}
