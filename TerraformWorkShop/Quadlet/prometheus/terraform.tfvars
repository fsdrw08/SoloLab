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

prov_grafana = {
  url  = "https://grafana.day1.sololab"
  auth = "admin:admin"
}

podman_kubes = [
  {
    helm = {
      name       = "prometheus"
      chart      = "../../../HelmWorkShop/helm-charts/charts/prometheus"
      value_file = "./attachments/values-sololab.yaml"
      secrets = [
        {
          vault_kvv2 = {
            mount = "kvv2-certs"
            name  = "prometheus.day1.sololab"
          }
          value_sets = [
            {
              name          = "prometheus.containers.server.tls.contents.ca\\.crt"
              value_ref_key = "ca"
            },
            {
              name          = "prometheus.containers.server.tls.contents.prometheus\\.crt"
              value_ref_key = "cert"
            },
            {
              name          = "prometheus.containers.server.tls.contents.prometheus\\.key"
              value_ref_key = "private_key"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2-vault_token"
            name  = "prometheus-metrics"
          }
          value_sets = [
            {
              name          = "prometheus.containers.server.tls.contents.vault-token"
              value_ref_key = "token"
            },
          ]
        },
        {
          vault_kvv2 = {
            mount = "kvv2-consul"
            name  = "token-prometheus"
          }
          value_sets = [
            {
              name          = "prometheus.containers.server.tls.contents.consul-token"
              value_ref_key = "token"
            },
          ]
        },
        # {
        #   value_sets = [
        #     # {
        #     #   name          = "prometheus.containers.blackboxExporter.tls.contents.ca\\.crt"
        #     #   value_ref_key = "ca"
        #     # },
        #     {
        #       name          = "prometheus.containers.blackboxExporter.tls.contents.blackboxExporter\\.crt"
        #       value_ref_key = "cert"
        #     },
        #     {
        #       name          = "prometheus.containers.blackboxExporter.tls.contents.blackboxExporter\\.key"
        #       value_ref_key = "private_key"
        #     },
        #   ]
        #   vault_kvv2 = {
        #     mount = "kvv2-certs"
        #     name  = "prometheus-blackbox-exporter.day1.sololab"
        #   }
        # }
      ]
    }
    manifest_dest_path = "/home/podmgr/.config/containers/systemd/prometheus-aio.yaml"
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
            # kube
            yaml          = "prometheus-aio.yaml"
            PodmanArgs    = "--tls-verify=false"
            KubeDownForce = "false"
            Network       = "host"
            # service
            ExecStartPre = ""
            ## https://community.grafana.com/t/ingester-is-not-ready-automatically-until-a-call-to-ready/100891/4
            # ExecStartPost = "/bin/bash -c \"sleep $(shuf -i 5-10 -n 1) && podman healthcheck run prometheus-server\""
            ExecStartPost = ""
            Restart       = "on-failure"
          }
        },
      ]
      service = {
        name   = "prometheus"
        status = "start"
      }
    },
  ]
}

prov_pdns = {
  api_key    = "powerdns"
  server_url = "https://pdns-auth.day0.sololab"
}

dns_records = [
  {
    zone = "day1.sololab."
    name = "prometheus.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1-fcos.node.consul."
    ]
  },
  {
    zone = "day1.sololab."
    name = "prometheus-blackbox-exporter.day1.sololab."
    type = "CNAME"
    ttl  = 86400
    records = [
      "day1-fcos.node.consul."
    ]
  },
]
