data "terraform_remote_state" "root_ca" {
  count   = var.podman_kube.helm.tls_value_sets.value_ref.tfstate == null ? 0 : 1
  backend = var.podman_kube.helm.tls_value_sets.value_ref.tfstate.backend.type
  config  = var.podman_kube.helm.tls_value_sets.value_ref.tfstate.backend.config
}

locals {
  cert = var.podman_kube.helm.tls_value_sets.value_ref.tfstate == null ? null : [
    for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
    if cert.name == var.podman_kube.helm.tls_value_sets.value_ref.tfstate.cert_name
  ]
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
      # ca
      tomap({
        "name"  = var.podman_kube.helm.tls_value_sets.name.ca,
        "value" = data.terraform_remote_state.root_ca[0].outputs.int_ca_pem
      }),
      # cert
      tomap({
        "name" = var.podman_kube.helm.tls_value_sets.name.cert,
        "value" = join("", [
          local.cert[0].cert_pem,
          data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
        ])
      }),
      # key
      tomap({
        "name"  = var.podman_kube.helm.tls_value_sets.name.private_key,
        "value" = local.cert[0].key_pem
      }),
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
}

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-vault.hcl"
  content = file("./podman-vault/service.hcl")
}
