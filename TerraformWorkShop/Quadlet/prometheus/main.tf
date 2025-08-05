# load cert from vault
locals {
  tls_vault_kvv2 = flatten([
    for podman_kube in var.podman_kubes : [
      for tls in podman_kube.helm.tls == null ? [] : podman_kube.helm.tls : {
        mount = tls.vault_kvv2.mount
        name  = tls.vault_kvv2.name
      }
    ]
  ])
}

data "vault_kv_secret_v2" "certs" {
  # count = var.podman_kube.helm.tls == null ? 0 : var.podman_kube.helm.tls.vault_kvv2 == null ? 0 : 1
  for_each = local.tls_vault_kvv2 == null ? null : {
    for tls_vault_kvv2 in local.tls_vault_kvv2 : tls_vault_kvv2.name => tls_vault_kvv2
  }
  mount = each.value.mount
  name  = each.value.name
}

# load cert from local tls
# data "terraform_remote_state" "root_ca" {
#   count   = var.podman_kube.helm.tls.tfstate == null ? 0 : 1
#   backend = var.podman_kube.helm.tls.tfstate.backend.type
#   config  = var.podman_kube.helm.tls.tfstate.backend.config
# }

# locals {
#   cert = var.podman_kube.helm.tls.tfstate == null ? null : [
#     for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
#     if cert.name == var.podman_kube.helm.tls.tfstate.cert_name
#   ]
# }

data "helm_template" "podman_kubes" {
  for_each = {
    for podman_kube in var.podman_kubes : podman_kube.helm.name => podman_kube
  }
  name  = each.value.helm.name
  chart = each.value.helm.chart

  values = [
    "${file(each.value.helm.value_file)}"
  ]

  # v2 helm provider
  # normal values
  # set = local.helm_value_sets
  # dynamic "set" {
  #   for_each = var.podman_kube.helm.value_sets == null ? [] : flatten([var.podman_kube.helm.value_sets])
  #   content {
  #     name = set.value.name
  #     value = set.value.value_string != null ? set.value.value_string : templatefile(
  #       "${set.value.value_template_path}", "${set.value.value_template_vars}"
  #     )
  #   }
  # }
  # # tls
  # dynamic "set" {
  #   for_each = var.podman_kube.helm.tls == null ? [] : flatten([var.podman_kube.helm.tls.value_sets])
  #   content {
  #     name  = set.value.name
  #     value = local.cert[0][set.value.value_ref_key]
  #   }
  # }

  # v3 helm provider
  set = flatten([
    each.value.helm.value_sets == null ? [] : [
      for value_set in flatten([each.value.helm.value_sets]) : {
        name = value_set.name
        value = value_set.value_string != null ? value_set.value_string : templatefile(
          "${value_set.value_template_path}", "${value_set.value_template_vars}"
        )
      }
    ],
    each.value.helm.tls == null ? [] : [
      for tls in each.value.helm.tls : [
        for value_set in tls.value_sets : {
          name = value_set.name
          # value = local.cert[0][value_set.value_ref_key]
          value = data.vault_kv_secret_v2.certs[tls.vault_kvv2.name].data[value_set.value_ref_key]
        }
      ]
    ],
  ])
}

resource "remote_file" "podman_kubes" {
  for_each = {
    for podman_kube in var.podman_kubes : podman_kube.helm.name => podman_kube
  }
  path    = each.value.manifest_dest_path
  content = data.helm_template.podman_kubes[each.key].manifest
}

module "podman_quadlet" {
  source  = "../../modules/system-systemd_quadlet"
  vm_conn = var.prov_remote
  podman_quadlet = {
    files = flatten([
      for unit in var.podman_quadlet.units : [
        for file in unit.files :
        {
          content = templatefile(
            file.template,
            file.vars
          )
          path = join("/", [
            var.podman_quadlet.dir,
            join(".", [
              unit.service.name,
              split(".", basename(file.template))[1]
            ])
          ])
        }
      ]
    ])
    services = [
      for unit in var.podman_quadlet.units : unit.service == null ? null :
      {
        name           = unit.service.name
        status         = unit.service.status
        custom_trigger = md5(remote_file.podman_kubes[unit.service.name].content)
      }
    ]
  }
}

resource "powerdns_record" "records" {
  for_each = {
    for record in var.dns_records : record.name => record
  }
  zone    = each.value.zone
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.records
}

resource "remote_file" "traefik_file_provider" {
  path    = "/var/home/podmgr/traefik-file-provider/prometheus-traefik.yaml"
  content = file("./podman-prometheus/prometheus-traefik.yaml")
}

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-prometheus.hcl"
  content = file("./podman-prometheus/service.hcl")
}

resource "grafana_data_source" "data_source" {
  depends_on = [module.podman_quadlet, powerdns_record.records]
  type       = "prometheus"
  name       = "prometheus"
  url        = "https://${trimsuffix(var.dns_records.0.name, ".")}"

  secure_json_data_encoded = jsonencode({
    tlsCACert = data.vault_kv_secret_v2.certs["${trimsuffix(var.dns_records.0.name, ".")}"].data["ca"]
  })

  json_data_encoded = jsonencode({
    tlsAuthWithCACert = true
  })
}

resource "grafana_dashboard" "dashboards" {
  for_each = toset([
    "./podman-prometheus/podman-exporter-dashboard.json",
    "./podman-prometheus/Blackbox-Exporter-Full.json",
    "./podman-prometheus/traefik-dashboard.json",
    "./podman-prometheus/vault-dashboard.json",
    "./podman-prometheus/consul-dashboard.json",
    "./podman-prometheus/minio-dashboard.json",
    "./podman-prometheus/zot-dashboard.json",
    "./podman-prometheus/loki-dashboard.json",
  ])
  config_json = templatefile(
    each.key,
    {
      DS_PROMETHEUS = grafana_data_source.data_source.uid
    }
  )
}
