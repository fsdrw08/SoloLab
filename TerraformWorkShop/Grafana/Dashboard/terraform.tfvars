prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

prov_grafana = {
  url  = "https://grafana.day1.sololab"
  auth = "admin:admin"
}

data_sources = [
  {
    iac_id = "1364b682"
    type   = "loki"
    name   = "loki"
    url    = "https://loki.day1.sololab"
  },
  {
    iac_id = "517bb05c"
    type   = "prometheus"
    name   = "prometheus"
    url    = "https://prometheus.day1.sololab"
  }
]

dashboards = [
  {
    template = "./attachments/podman-exporter-dashboard.json"
    vars = {
      data_source = "517bb05c"
    }
  },
  {
    template = "./attachments/Blackbox-Exporter-Full.json"
    vars = {
      data_source = "517bb05c"
    }
  },
  {
    template = "./attachments/traefik-dashboard.json"
    vars = {
      data_source = "517bb05c"
    }
  },
  {
    template = "./attachments/vault-dashboard.json"
    vars = {
      data_source = "517bb05c"
    }
  },
  {
    template = "./attachments/consul-dashboard.json"
    vars = {
      data_source = "517bb05c"
    }
  },
  {
    template = "./attachments/minio-dashboard.json"
    vars = {
      data_source = "517bb05c"
    }
  },
  {
    template = "./attachments/zot-dashboard.json"
    vars = {
      data_source = "517bb05c"
    }
  },
  {
    template = "./attachments/coredns-dashboard.json"
    vars = {
      data_source = "517bb05c"
    }
  }
]
