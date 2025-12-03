data "vault_kv_secret_v2" "secrets" {
  for_each = {
    sololab_root = {
      mount = "kvv2_certs"
      name  = "sololab_root"
    }
  }
  mount = each.value.mount
  name  = each.value.name
}

resource "grafana_data_source" "data_sources" {
  for_each = {
    for ds in var.data_sources : ds.iac_id => ds
  }
  type = each.value.type
  name = each.value.name
  url  = each.value.url

  secure_json_data_encoded = jsonencode({
    tlsCACert = data.vault_kv_secret_v2.secrets["sololab_root"].data["ca"]
  })

  json_data_encoded = jsonencode({
    tlsAuthWithCACert = true
  })
}

resource "grafana_dashboard" "dashboards" {
  # for_each = toset([
  #   "./attachments/podman-exporter-dashboard.json",
  #   "./attachments/Blackbox-Exporter-Full.json",
  #   "./attachments/traefik-dashboard.json",
  #   "./attachments/vault-dashboard.json",
  #   "./attachments/consul-dashboard.json",
  #   "./attachments/minio-dashboard.json",
  #   "./attachments/zot-dashboard.json",
  #   "./attachments/coredns-dashboard.json",
  # ])
  # config_json = templatefile(
  #   each.key,
  #   {
  #     DS_PROMETHEUS = grafana_data_source.data_source.uid
  #   }
  # )
  for_each = {
    for dashboard in var.dashboards : dashboard.template => dashboard
  }
  config_json = templatefile(
    each.value.template,
    {
      DS_PROMETHEUS = lookup(each.value.vars, "DS_PROMETHEUS", null) == null ? null : grafana_data_source.data_sources[lookup(each.value.vars, "DS_PROMETHEUS")].uid
      DS_LOKI       = lookup(each.value.vars, "DS_LOKI", null) == null ? null : grafana_data_source.data_sources[lookup(each.value.vars, "DS_LOKI")].uid
    }
  )
}
