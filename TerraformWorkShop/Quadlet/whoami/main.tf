# data "vault_kv_secret_v2" "cert" {
#   count = var.podman_kube.helm.secrets_value_sets == null ? 0 : 1
#   mount = var.podman_kube.helm.secrets_value_sets.value_ref.vault_kvv2.mount
#   name  = var.podman_kube.helm.secrets_value_sets.value_ref.vault_kvv2.name
# }

# data "helm_template" "podman_kube" {
#   name  = var.podman_kube.helm.name
#   chart = var.podman_kube.helm.chart

#   values = [
#     "${file(var.podman_kube.helm.value_file)}"
#   ]
#   # normal values
#   dynamic "set" {
#     for_each = var.podman_kube.helm.value_sets == null ? [] : flatten([var.podman_kube.helm.value_sets])
#     content {
#       name = set.value.name
#       value = set.value.value_string != null ? set.value.value_string : templatefile(
#         "${set.value.value_template_path}", "${set.value.value_template_vars}"
#       )
#     }
#   }
#   # tls values
#   dynamic "set" {
#     for_each = var.podman_kube.helm.secrets_value_sets == null ? [] : flatten([var.podman_kube.helm.secrets_value_sets.value_sets])
#     content {
#       name  = set.value.name
#       value = data.vault_kv_secret_v2.cert[0].data[set.value.value_ref_key]
#     }
#   }
# }


resource "remote_file" "podman_kube" {
  # depends_on = [null_resource.init]
  path    = var.podman_kube.manifest_dest_path
  content = file("./podman-whoami/whoami-aio.yaml")
}

module "podman_quadlet" {
  depends_on = [
    remote_file.podman_kube,
  ]
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
        custom_trigger = md5(remote_file.podman_kube.content)
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

# resource "remote_file" "consul_service" {
#   path    = "/var/home/podmgr/consul-services/service-whoami.hcl"
#   content = file("./podman-whoami/service.hcl")
# }
