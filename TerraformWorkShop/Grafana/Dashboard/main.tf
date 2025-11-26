data "vault_kv_secret_v2" "secrets" {
  for_each = {
    sololab_root = {
      mount = "kvv2-certs"
      name  = "sololab_root"
    }
  }
  mount = each.value.mount
  name  = each.value.name
}

resource "grafana_data_source" "data_source" {
  type = "prometheus"
  name = "prometheus"
  url  = "https://prometheus.day1.sololab"

  secure_json_data_encoded = jsonencode({
    tlsCACert = data.vault_kv_secret_v2.secrets["sololab_root"].data["ca"]
  })

  json_data_encoded = jsonencode({
    tlsAuthWithCACert = true
  })
}


resource "grafana_dashboard" "dashboards" {
  for_each = toset([
    "./attachments/podman-exporter-dashboard.json",
    "./attachments/Blackbox-Exporter-Full.json",
    "./attachments/traefik-dashboard.json",
    "./attachments/vault-dashboard.json",
    "./attachments/consul-dashboard.json",
    "./attachments/minio-dashboard.json",
    "./attachments/zot-dashboard.json",
    "./attachments/coredns-dashboard.json",
  ])
  config_json = templatefile(
    each.key,
    {
      DS_PROMETHEUS = grafana_data_source.data_source.uid
    }
  )
}
