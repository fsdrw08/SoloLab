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

# data "vault_kv_secret_v2" "certs" {
#   # count = var.podman_kube.helm.tls == null ? 0 : var.podman_kube.helm.tls.vault_kvv2 == null ? 0 : 1
#   for_each = local.tls_vault_kvv2 == null ? null : {
#     for tls_vault_kvv2 in local.tls_vault_kvv2 : tls_vault_kvv2.name => tls_vault_kvv2
#   }
#   mount = each.value.mount
#   name  = each.value.name
# }

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
          name = value_set.name
          # value = tls.tfstate == null ? data.vault_kv_secret_v2.certs[tls.vault_kvv2.name].data[value_set.value_ref_key] : local.certs[tls.tfstate.cert_name][value_set.value_ref_key]
          value = tls.tfstate == null ? null : local.certs[tls.tfstate.cert_name][value_set.value_ref_key]
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
  source  = "../../modules/system-systemd_quadlet-root"
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

resource "powerdns_record" "record" {
  zone    = var.dns_record.zone
  name    = var.dns_record.name
  type    = var.dns_record.type
  ttl     = var.dns_record.ttl
  records = var.dns_record.records
}

# resource "null_resource" "post_process" {
#   depends_on = [
#     powerdns_record.record,
#     module.podman_quadlet
#   ]
#   for_each = var.post_process == null ? {} : var.post_process
#   triggers = {
#     script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
#   }
#   connection {
#     type     = "ssh"
#     host     = var.prov_remote.host
#     port     = var.prov_remote.port
#     user     = var.prov_remote.user
#     password = sensitive(var.prov_remote.password)
#   }
#   provisioner "remote-exec" {
#     inline = [
#       templatefile("${each.value.script_path}", "${each.value.vars}")
#     ]
#   }
# }

# resource "remote_file" "traefik_file_provider" {
#   path    = "/var/home/podmgr/traefik-file-provider/nomad-traefik.yaml"
#   content = file("./podman-nomad/nomad-traefik.yaml")
# }

# resource "remote_file" "consul_service" {
#   path    = "/var/home/podmgr/consul-services/service-nomad.hcl"
#   content = file("./podman-nomad/service.hcl")
# }
