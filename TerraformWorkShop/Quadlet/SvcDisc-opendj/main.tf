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

data "jks_keystore" "keystore" {
  password = "changeit"

  key_pair {
    alias       = "sololab"
    certificate = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.cert]
    private_key = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.private_key]
    intermediate_certificates = [
      data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.ca],
    ]
  }
}

# resource "pkcs12_from_pem" "keystore" {
#   password        = "changeit"
#   ca_pem          = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.ca]
#   cert_pem        = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.cert]
#   private_key_pem = data.vault_kv_secret_v2.cert[0].data[var.podman_kube.helm.tls_value_sets.value_ref.vault_kvv2.data_key.private_key]
#   # ca_pem = [
#   #   data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
#   # ]
#   # cert_pem        = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_cert_pem), var.certs.cert_content_tfstate_entity, null)
#   # private_key_pem = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_key), var.certs.cert_content_tfstate_entity, null)
# }

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
        "name" = var.podman_kube.helm.tls_value_sets.name,
        # "value" = pkcs12_from_pem.keystore.result
        "value" = data.jks_keystore.keystore.jks_base64
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
  conn {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = sensitive(var.vm_conn.password)
  }

  connection {
    type     = "ssh"
    host     = self.conn[0].host
    port     = self.conn[0].port
    user     = self.conn[0].user
    password = self.conn[0].password
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user daemon-reload",
    ]
  }
}

# # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
resource "remote_file" "podman_quadlet" {
  depends_on = [remote_file.podman_kube]
  for_each = {
    for content in var.podman_quadlet.quadlet.file_contents : content.file_source => content
  }
  path = join("/", [
    var.podman_quadlet.quadlet.file_path_dir,
    basename("${each.value.file_source}")
  ])
  content = templatefile(
    each.value.file_source,
    each.value.vars
  )
}

resource "null_resource" "podman_quadlet" {
  depends_on = [
    remote_file.podman_kube,
    remote_file.podman_quadlet
  ]
  triggers = {
    service_name = var.podman_quadlet.service.name
    quadlet_md5  = md5(join("\n", [for quadlet in remote_file.podman_quadlet : quadlet.content]))
    host         = var.vm_conn.host
    port         = var.vm_conn.port
    user         = var.vm_conn.user
    password     = sensitive(var.vm_conn.password)
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
      "systemctl --user daemon-reload",
      "systemctl --user ${var.podman_quadlet.service.status} ${self.triggers.service_name}",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user stop ${self.triggers.service_name}",
    ]
  }
}

module "container_restart" {
  depends_on = [null_resource.podman_quadlet]
  source     = "../../modules/system-systemd_path_user"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
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

# resource "vyos_static_host_mapping" "host_mapping" {
#   depends_on = [
#     null_resource.podman_quadlet,
#   ]
#   host = "traefik.day0.sololab"
#   ip   = "192.168.255.20"
# }

locals {
  post_process = {
    Disable-AnonymousAccess = {
      script_path = "./podman-opendj/Disable-AnonymousAccess.sh"
      vars = {
        CONTAINER_NAME = "opendj-opendj"
        hostname       = "localhost"
        bindDN         = "cn=Directory Manager"
        bindPassword   = "P@ssw0rd"
      }
    }
  }
}

resource "null_resource" "post_process" {
  depends_on = [module.container_restart]
  for_each   = local.post_process
  triggers = {
    script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
    host           = var.vm_conn.host
    port           = var.vm_conn.port
    user           = var.vm_conn.user
    password       = sensitive(var.vm_conn.password)
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

resource "powerdns_record" "record" {
  zone    = var.dns_record.zone
  name    = var.dns_record.name
  type    = var.dns_record.type
  ttl     = var.dns_record.ttl
  records = var.dns_record.records
}
