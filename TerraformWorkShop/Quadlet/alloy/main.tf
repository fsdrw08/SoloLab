# load cert from vault
data "vault_kv_secret_v2" "cert" {
  count = var.podman_kube.helm.tls == null ? 0 : var.podman_kube.helm.tls.vault_kvv2 == null ? 0 : 1
  mount = var.podman_kube.helm.tls.vault_kvv2.mount
  name  = var.podman_kube.helm.tls.vault_kvv2.name
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

data "helm_template" "podman_kube" {
  name  = var.podman_kube.helm.name
  chart = var.podman_kube.helm.chart

  values = [
    "${file(var.podman_kube.helm.value_file)}"
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
    var.podman_kube.helm.value_sets == null ? [] : [
      for value_set in flatten([var.podman_kube.helm.value_sets]) : {
        name = value_set.name
        value = value_set.value_string != null ? value_set.value_string : templatefile(
          "${value_set.value_template_path}", "${value_set.value_template_vars}"
        )
      }
    ],
    var.podman_kube.helm.tls == null ? [] : [
      for value_set in flatten([var.podman_kube.helm.tls.value_sets]) : {
        name = value_set.name
        # value = local.cert[0][value_set.value_ref_key]
        value = data.vault_kv_secret_v2.cert[0].data[value_set.value_ref_key]
      }
    ],
  ])
}

resource "remote_file" "podman_kube_day0" {
  provider = remote.Day0
  path     = var.podman_kube.manifest_dest_path
  content  = data.helm_template.podman_kube.manifest
}

resource "remote_file" "podman_kube_day1" {
  provider = remote.Day1
  path     = var.podman_kube.manifest_dest_path
  content  = data.helm_template.podman_kube.manifest
}

module "podman_quadlet_day0" {
  source = "../../modules/system-systemd_quadlet"
  providers = {
    remote = remote.Day0
  }
  vm_conn = var.prov_remote.0
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
        custom_trigger = md5(remote_file.podman_kube_day0.content)
      }
    ]
  }
}

module "podman_quadlet_day1" {
  source = "../../modules/system-systemd_quadlet"
  providers = {
    remote = remote.Day1
  }
  vm_conn = var.prov_remote.1
  podman_quadlet = {
    services = [
      for unit in var.podman_quadlet.units : unit.service == null ? null :
      {
        name           = unit.service.name
        status         = unit.service.status
        custom_trigger = md5(remote_file.podman_kube_day0.content)
      }
    ]
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

resource "remote_file" "traefik_file_provider_day0" {
  provider = remote.Day0
  path     = "/var/home/podmgr/traefik-file-provider/alloy-traefik.yaml"
  content  = file("./podman-alloy/alloy-traefik.yaml")
}

resource "remote_file" "traefik_file_provider_day1" {
  provider = remote.Day1
  path     = "/var/home/podmgr/traefik-file-provider/alloy-traefik.yaml"
  content  = file("./podman-alloy/alloy-traefik.yaml")
}

resource "remote_file" "consul_service_day0" {
  provider = remote.Day0
  path     = "/var/home/podmgr/consul-services/service-alloy.hcl"
  content  = file("./podman-alloy/service-day0.hcl")
}

resource "remote_file" "consul_service_day1" {
  provider = remote.Day1
  path     = "/var/home/podmgr/consul-services/service-alloy.hcl"
  content  = file("./podman-alloy/service-day1.hcl")
}
