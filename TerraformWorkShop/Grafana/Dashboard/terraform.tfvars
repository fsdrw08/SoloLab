prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_grafana = {
  url                  = "https://grafana.day2.sololab"
  insecure_skip_verify = true
  auth_reference = {
    vault_kvv2 = {
      mount = "kvv2_others"
      name  = "grafana"
      key   = "auth"
    }
  }
}

data_sources = [
  {
    # iac_id is used to link the data source with the dashboard variables in terraform side
    # get generate by:
    # powershell: new-guid
    # bash: uuidgen
    iac_id = "1364b682"
    type   = "loki"
    name   = "loki"
    url    = "https://loki.day2.sololab"
  },
  {
    iac_id = "517bb05c"
    type   = "prometheus"
    name   = "prometheus"
    url    = "https://prometheus.day2.sololab"
  }
]

dashboards = [
  {
    template = "./attachments/Node-Exporter-Full.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/podman-exporter-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/Blackbox-Exporter-Full.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/Etcd-Cluster-Dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/Consul-Exporter-Dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/traefik-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/minio-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/zot-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/coredns-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/vault-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/consul-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/nomad-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/postgres-exporter-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/redis-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
  {
    template = "./attachments/nexus3-dashboard.json"
    vars = {
      DS_PROMETHEUS = "517bb05c"
    }
  },
]
