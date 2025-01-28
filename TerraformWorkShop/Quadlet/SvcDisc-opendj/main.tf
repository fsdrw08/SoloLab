# data "terraform_remote_state" "root_ca" {
#   count   = var.certs_ref.tfstate == null ? 0 : 1
#   backend = var.certs_ref.tfstate.backend.type
#   config  = var.certs_ref.tfstate.backend.config
# }

data "vault_kv_secret_v2" "cert" {
  count = var.podman_kube.helm.tls_value_sets == null ? 0 : 1
  mount = var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.mount
  name  = var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.name
}

resource "pkcs12_from_pem" "keystore" {
  password        = "changeit"
  ca_pem          = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.ca]
  cert_pem        = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.cert]
  private_key_pem = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.private_key]
  # ca_pem = [
  #   data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
  # ]
  # cert_pem        = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_cert_pem), var.certs.cert_content_tfstate_entity, null)
  # private_key_pem = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_key), var.certs.cert_content_tfstate_entity, null)
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
    for_each = var.podman_kube.helm.tls_value_sets == null ? [] : [
      # pkcs12
      tomap({
        "name"  = var.podman_kube.helm.tls_value_sets.name,
        "value" = pkcs12_from_pem.keystore.result
      })
    ]
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
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

resource "null_resource" "post_process" {
  depends_on = [
    powerdns_record.record,
    module.podman_quadlet
  ]
  for_each = var.post_process == null ? {} : var.post_process
  triggers = {
    script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
    host           = var.prov_remote.host
    port           = var.prov_remote.port
    user           = var.prov_remote.user
    password       = sensitive(var.prov_remote.password)
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${each.value.script_path}", "${each.value.vars}")
    ]
  }
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -f ${self.triggers.file_source}/traefik",
  #   ]
  # }
}
