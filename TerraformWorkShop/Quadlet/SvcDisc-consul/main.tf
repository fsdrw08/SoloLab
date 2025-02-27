resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
  triggers = {
    dirs = "/home/podmgr/consul-services"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/podman-consul/init.sh", {
        dirs = self.triggers.dirs
      })
    ]
  }
}

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
  # normal values
  dynamic "set" {
    for_each = var.podman_kube.helm.value_sets == null ? [] : flatten([var.podman_kube.helm.value_sets])
    content {
      name = set.value.name
      value = set.value.value_string != null ? set.value.value_string : templatefile(
        "${set.value.value_template_path}", "${set.value.value_template_vars}"
      )
    }
  }
  # tls values
  dynamic "set" {
    for_each = var.podman_kube.helm.tls_value_sets == null ? [] : flatten([var.podman_kube.helm.tls_value_sets.value_sets])
    content {
      name  = set.value.name
      value = data.vault_kv_secret_v2.cert[0].data[set.value.value_ref_key]
    }
  }
}

resource "remote_file" "consul_service" {
  depends_on = [null_resource.init]
  path       = "/var/home/podmgr/consul-services/service-consul.hcl"
  content    = file("./podman-consul/service.hcl")
}

resource "remote_file" "podman_kube" {
  depends_on = [null_resource.init]
  path       = var.podman_kube.manifest_dest_path
  content    = data.helm_template.podman_kube.manifest
}

module "podman_quadlet" {
  depends_on = [
    remote_file.podman_kube,
  ]
  source  = "../../modules/system-systemd_quadlet"
  vm_conn = var.prov_remote
  podman_quadlet = {
    service = {
      name           = var.podman_quadlet.service.name
      status         = var.podman_quadlet.service.status
      custom_trigger = md5(remote_file.podman_kube.content)
    }
    files = [
      for file in var.podman_quadlet.files :
      {
        content = templatefile(
          file.template,
          file.vars
        )
        path = join("/", [
          file.dir,
          basename("${file.template}")
        ])
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

resource "null_resource" "post_process" {
  depends_on = [
    powerdns_record.record,
    module.podman_quadlet
  ]
  for_each = var.post_process == null ? {} : var.post_process
  triggers = {
    script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
  }
  connection {
    type     = "ssh"
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = sensitive(var.prov_remote.password)
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${each.value.script_path}", "${each.value.vars}")
    ]
  }
}
