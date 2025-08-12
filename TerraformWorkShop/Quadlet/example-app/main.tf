data "vault_kv_secret_v2" "cert" {
  mount = "kvv2/certs"
  name  = "root"
}

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

data "vault_identity_oidc_openid_config" "config" {
  name = "sololab"
}

data "vault_identity_oidc_client_creds" "creds" {
  name = "example-app"
}


resource "remote_file" "podman_kube" {
  # depends_on = [null_resource.init]
  path = var.podman_kube.manifest_dest_path
  content = templatefile("./podman-example-app/example-app-aio.yaml",
    {
      ca           = base64encode(data.vault_kv_secret_v2.cert.data["ca"])
      issuer       = data.vault_identity_oidc_openid_config.config.issuer
      clientId     = data.vault_identity_oidc_client_creds.creds.client_id
      clientSecret = data.vault_identity_oidc_client_creds.creds.client_secret
    }
  )
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
          var.podman_quadlet.dir,
          join(".", [
            var.podman_quadlet.service.name,
            split(".", basename(file.template))[1]
          ])
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

resource "remote_file" "consul_service" {
  for_each = toset([
    "./attachments/example.consul.hcl",
  ])
  path    = "/var/home/podmgr/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
