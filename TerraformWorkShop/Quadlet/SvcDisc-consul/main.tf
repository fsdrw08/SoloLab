data "vault_kv_secret_v2" "cert" {
  count = var.podman_kube.helm.tls_value_sets == null ? 0 : 1
  mount = var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.mount
  name  = var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.name
}

data "helm_template" "podman_kube" {
  name  = var.podman_kube.helm.name
  chart = var.podman_kube.helm.chart

  values = [
    "${file(var.podman_kube.helm.value_file)}"
  ]

  dynamic "set" {
    for_each = var.podman_kube.helm.value_sets == null ? [] : flatten([var.podman_kube.helm.value_sets])
    content {
      name = set.value.name
      value = set.value.value_string != null ? set.value.value_string : templatefile(
        "${set.value.value_template_path}", "${set.value.value_template_vars}"
      )
    }
  }
  # tls
  dynamic "set" {
    for_each = var.podman_kube.helm.tls_value_sets == null ? [] : flatten([var.podman_kube.helm.tls_value_sets.value_sets])
    # ca
    #   tomap({
    #     "name"  = var.podman_kube.helm.tls_value_sets.name.ca,
    #     "value" = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.ca]
    #   }),
    #   # cert
    #   tomap({
    #     "name"  = var.podman_kube.helm.tls_value_sets.name.cert,
    #     "value" = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.cert]
    #   }),
    #   # key
    #   tomap({
    #     "name"  = var.podman_kube.helm.tls_value_sets.name.private_key,
    #     "value" = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.private_key]
    #   }),
    # ]
    content {
      name  = set.value.name
      value = data.vault_kv_secret_v2.cert[0].data[set.value.value_ref_key]
    }
  }
  # set {
  #   name  = "consul.configFiles.general.auto_config.authorization.static.oidc_discovery_ca_cert"
  #   value = data.terraform_remote_state.root_ca.outputs.int_ca_pem
  # }
  # set {
  #   name = "consul.tls.contents.\"server\\.crt\""
  #   value = join("", [
  #     lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "consul", null),
  #     data.terraform_remote_state.root_ca.outputs.int_ca_pem,
  #   ])
  # }
  # set {
  #   name  = "consul.tls.contents.\"server\\.key\""
  #   value = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "consul", null)
  # }
  # set {
  #   name  = "consul.tls.contents.\"ca\\.crt\""
  #   value = data.terraform_remote_state.root_ca.outputs.int_ca_pem
  # }
}

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.manifest_dest_path
  content = data.helm_template.podman_kube.manifest
}

module "podman_quadlet" {
  depends_on     = [remote_file.podman_kube]
  source         = "../../modules/system-systemd_quadlet"
  vm_conn        = var.prov_remote
  podman_quadlet = var.podman_quadlet
}


# # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
# resource "remote_file" "podman_quadlet" {
#   depends_on = [remote_file.podman_kube]
#   for_each = {
#     for content in var.podman_quadlet.quadlet.file_contents : content.file_source => content
#   }
#   path = join("/", [
#     var.podman_quadlet.quadlet.file_path_dir,
#     basename("${each.value.file_source}")
#   ])
#   content = templatefile(
#     each.value.file_source,
#     each.value.vars
#   )
# }

# resource "null_resource" "podman_quadlet" {
#   depends_on = [
#     remote_file.podman_kube,
#     remote_file.podman_quadlet
#   ]
#   triggers = {
#     service_name = var.podman_quadlet.service.name
#     quadlet_md5  = md5(join("\n", [for quadlet in remote_file.podman_quadlet : quadlet.content]))
#     host         = var.vm_conn.host
#     port         = var.vm_conn.port
#     user         = var.vm_conn.user
#     password     = sensitive(var.vm_conn.password)
#   }
#   connection {
#     type     = "ssh"
#     host     = self.triggers.host
#     port     = self.triggers.port
#     user     = self.triggers.user
#     password = self.triggers.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "systemctl --user daemon-reload",
#       "systemctl --user ${var.podman_quadlet.service.status} ${self.triggers.service_name}",
#     ]
#   }
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "systemctl --user stop ${self.triggers.service_name}",
#     ]
#   }
# }

module "container_restart" {
  depends_on = [module.podman_quadlet]
  source     = "../../modules/system-systemd_path_user"
  vm_conn = {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
  systemd_path_unit = {
    content = templatefile(
      var.container_restart.systemd_path_unit.content.templatefile,
      var.container_restart.systemd_path_unit.content.vars
    )
    path = var.container_restart.systemd_path_unit.path
  }
  systemd_service_unit = {
    content = templatefile(
      var.container_restart.systemd_service_unit.content.templatefile,
      var.container_restart.systemd_service_unit.content.vars
    )
    path = var.container_restart.systemd_service_unit.path
  }
}

resource "powerdns_record" "record" {
  zone    = var.dns_record.zone
  name    = var.dns_record.name
  type    = var.dns_record.type
  ttl     = var.dns_record.ttl
  records = var.dns_record.records
}

# resource "vyos_static_host_mapping" "host_mapping" {
#   depends_on = [
#     null_resource.podman_quadlet,
#   ]
#   host = "consul.day0.sololab"
#   ip   = "192.168.255.20"
# }

# locals {
#   post_process = {
#     New-VaultStaticToken = {
#       script_path = "./podman-vault/New-VaultStaticToken.sh"
#       vars = {
#         VAULT_OPERATOR_SECRETS_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-file/_data/vault_operator_secret"
#         VAULT_ADDR                  = "https://vault.day0.sololab:8200"
#         STATIC_TOKEN                = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
#       }
#     }
#   }
# }

# resource "null_resource" "post_process" {
#   depends_on = [vyos_static_host_mapping.host_mapping]
#   for_each   = local.post_process
#   triggers = {
#     script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
#     host           = var.vm_conn.host
#     port           = var.vm_conn.port
#     user           = var.vm_conn.user
#     password       = sensitive(var.vm_conn.password)
#   }
#   connection {
#     type     = "ssh"
#     host     = self.triggers.host
#     port     = self.triggers.port
#     user     = self.triggers.user
#     password = self.triggers.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       templatefile("${each.value.script_path}", "${each.value.vars}")
#     ]
#   }
#   # provisioner "remote-exec" {
#   #   when = destroy
#   #   inline = [
#   #     "sudo rm -f ${self.triggers.file_source}/consul",
#   #   ]
#   # }
# }
