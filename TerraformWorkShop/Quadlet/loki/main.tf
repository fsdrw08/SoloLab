# get minio access id and secret id from vault
data "vault_kv_secret_v2" "minio" {
  mount = "kvv2/minio"
  name  = "loki"
}

# load cert from vault
locals {
  tls_vault_kvv2 = flatten([
    for podman_kube in var.podman_kubes : [
      for tls in podman_kube.helm.tls == null ? [] : podman_kube.helm.tls : {
        mount = tls.vault_kvv2.mount
        name  = tls.vault_kvv2.name
      }
      if tls.vault_kvv2 != null
    ]
  ])
  tls_tfstate = flatten([
    for podman_kube in var.podman_kubes : [
      for tls in podman_kube.helm.tls == null ? [] : podman_kube.helm.tls : {
        backend = tls.tfstate.backend
        name    = tls.tfstate.cert_name
      }
      if tls.tfstate != null
    ]
  ])
}

data "vault_kv_secret_v2" "certs" {
  for_each = local.tls_vault_kvv2 == null ? null : {
    for tls_vault_kvv2 in local.tls_vault_kvv2 : tls_vault_kvv2.name => tls_vault_kvv2
  }
  mount = each.value.mount
  name  = each.value.name
}

# load cert from local tls
data "terraform_remote_state" "tfstate" {
  # count   = var.podman_kube.helm.tls.tfstate == null ? 0 : 1
  for_each = local.tls_tfstate == null ? null : {
    for tls_tfstate in local.tls_tfstate : tls_tfstate.name => tls_tfstate
  }
  backend = each.value.backend.type
  config  = each.value.backend.config
}

locals {
  cert_list = data.terraform_remote_state.tfstate == null ? null : flatten([
    for podman_kube in var.podman_kubes : [
      for tls in podman_kube.helm.tls == null ? [] : podman_kube.helm.tls : [
        for cert in data.terraform_remote_state.tfstate[tls.tfstate.cert_name].outputs.signed_certs : cert
        if cert.name == tls.tfstate.cert_name
      ]
      if tls.tfstate != null
    ]
  ])
  certs = data.terraform_remote_state.tfstate == null ? null : {
    for cert in local.cert_list : cert.name => cert
  }
}

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
          name  = value_set.name
          value = tls.tfstate == null ? data.vault_kv_secret_v2.certs[tls.vault_kvv2.name].data[value_set.value_ref_key] : local.certs[tls.tfstate.cert_name][value_set.value_ref_key]
        }
      ]
    ],
    flatten([
      {
        name  = "loki.config.storage_config.object_store.s3.access_key_id"
        value = data.vault_kv_secret_v2.minio.data["access_key"]
      },
      {
        name  = "loki.config.storage_config.object_store.s3.secret_access_key"
        value = data.vault_kv_secret_v2.minio.data["secret_key"]
      },
    ])
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
  path    = "/var/home/podmgr/traefik-file-provider/loki-traefik.yaml"
  content = file("./podman-loki/loki-traefik.yaml")
}

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-loki.hcl"
  content = file("./podman-loki/service.hcl")
}

resource "grafana_data_source" "data_source" {
  type = "loki"
  name = "loki"
  url  = "https://${trimsuffix(var.dns_records.0.name, ".")}"

  secure_json_data_encoded = jsonencode({
    tlsCACert = data.vault_kv_secret_v2.certs["loki.day1.sololab"].data["ca"]
  })

  json_data_encoded = jsonencode({
    tlsAuthWithCACert = true
  })
}
