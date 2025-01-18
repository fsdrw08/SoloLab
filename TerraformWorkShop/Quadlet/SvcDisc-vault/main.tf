data "terraform_remote_state" "root_ca" {
  count   = var.certs_ref.tfstate == null ? 0 : 1
  backend = var.certs_ref.tfstate.backend
  config  = var.certs_ref.tfstate.config
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
  set {
    name  = var.certs_ref.config_node.ca == null ? null : var.certs_ref.config_node.ca
    value = var.certs_ref.tfstate == null ? null : data.terraform_remote_state.root_ca[0].outputs.int_ca_pem
  }
  set {
    name = var.certs_ref.config_node.cert == null ? null : var.certs_ref.config_node.cert
    value = var.certs_ref.tfstate == null ? null : join("", [
      lookup((data.terraform_remote_state.root_ca[0].outputs.signed_cert_pem), var.certs_ref.tfstate.entity, null),
      data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
    ])
  }
  set {
    name  = var.certs_ref.config_node.key == null ? null : var.certs_ref.config_node.key
    value = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_key), var.certs_ref.tfstate.entity, null)
  }
  # set {
  #   name = "vault.tls.contents.\"tls\\.crt\""
  #   value = join("", [
  #     lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "vault", null),
  #     data.terraform_remote_state.root_ca.outputs.int_ca_pem,
  #   ])
  # }
  # set {
  #   name  = "vault.tls.contents.\"tls\\.key\""
  #   value = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "vault", null)
  # }
  # set {
  #   name  = "vault.tls.contents.\"ca\\.crt\""
  #   value = data.terraform_remote_state.root_ca.outputs.int_ca_pem
  # }
}

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.yaml_file_path
  content = data.helm_template.podman_kube.manifest
  conn {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = sensitive(var.prov_remote.password)
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
  # path = format("${var.podman_quadlet.quadlet.file_path_dir}/%s", basename("${each.value.file_source}"))
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
    host         = var.prov_remote.host
    port         = var.prov_remote.port
    user         = var.prov_remote.user
    password     = sensitive(var.prov_remote.password)
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

locals {
  post_process = {
    # Init-Vault = {
    #   script_path = "./podman-vault/Init-VaultByCurl.sh"
    #   vars = {
    #     VAULT_OPERATOR_SECRETS_JSON_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-file/_data/vault_operator_secret.json"
    #     VAULT_ADDR                       = "https://vault.day1.sololab:8200"
    #     STATIC_TOKEN                     = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
    #   }
    # }
    New-VaultStaticToken = {
      script_path = "./podman-vault/New-VaultStaticToken.sh"
      vars = {
        VAULT_OPERATOR_SECRETS_JSON_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-unseal/_data/vault_operator_secrets"
        # VAULT_OPERATOR_SECRETS_PATH = "/home/podmgr/.local/share/containers/storage/volumes/vault-pvc-file/_data/vault_operator_secret"
        VAULT_ADDR   = "https://vault.day1.sololab:8200"
        STATIC_TOKEN = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
      }
    }
  }
}

resource "null_resource" "post_process" {
  depends_on = [
    powerdns_record.record,
    null_resource.podman_quadlet
  ]
  for_each = local.post_process
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
  #     "sudo rm -f ${self.triggers.file_source}/consul",
  #   ]
  # }
}
