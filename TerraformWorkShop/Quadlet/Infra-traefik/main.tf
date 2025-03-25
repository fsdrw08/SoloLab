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

# resource "remote_file" "http_socket" {
#   content = templatefile(
#     "./podman-traefik/http.socket",
#     {
#       name = "traefik-container"
#     }
#   )
#   path = "/home/podmgr/.config/systemd/user/http.socket"
# }

# resource "remote_file" "https_socket" {
#   content = templatefile(
#     "./podman-traefik/https.socket",
#     {
#       name = "traefik-container"
#     }
#   )
#   path = "/home/podmgr/.config/systemd/user/https.socket"
# }

# resource "null_resource" "service_stop" {
#   depends_on = [
#     remote_file.http_socket,
#     remote_file.https_socket
#   ]
#   triggers = {
#     service_name = "http.socket https.socket"
#     host         = var.prov_remote.host
#     port         = var.prov_remote.port
#     user         = var.prov_remote.user
#     password     = sensitive(var.prov_remote.password)
#   }
#   connection {
#     type     = "ssh"
#     host     = self.triggers.host
#     port     = self.triggers.port
#     user     = self.triggers.user
#     password = self.triggers.password
#   }
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "systemctl --user stop ${self.triggers.service_name}",
#     ]
#   }
# }

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
  # tls
  dynamic "set" {
    for_each = var.podman_kube.helm.tls_value_sets == null ? [] : [
      # ca
      tomap({
        "name"  = var.podman_kube.helm.tls_value_sets.tfstate.data_key.ca,
        "value" = data.terraform_remote_state.root_ca[0].outputs.int_ca_pem
      }),
      # cert
      tomap({
        "name" = var.podman_kube.helm.tls_value_sets.tfstate.data_key.cert,
        "value" = join("", [
          local.cert[0].cert_pem,
          data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
        ])
      }),
      # key
      tomap({
        "name"  = var.podman_kube.helm.tls_value_sets.tfstate.data_key.private_key,
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
}

module "podman_quadlet" {
  depends_on = [
    # remote_file.podman_quadlet,
    # remote_file.http_socket,
    # remote_file.https_socket,
    # null_resource.service_stop
  ]
  source  = "../../modules/system-systemd_quadlet"
  vm_conn = var.prov_remote
  podman_quadlet = {
    service = {
      name   = var.podman_quadlet.service.name
      status = var.podman_quadlet.service.status
    }
    files = [
      for file in var.podman_quadlet.files :
      {
        content = templatefile(
          file.template,
          merge(
            file.vars,
            {
              ca = base64encode(
                join("", [
                  local.cert[0].cert_pem,
                  data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
                ])
              )
              # cert = base64encode(data.vault_kv_secret_v2.cert[0].data["cert"])
              # key  = base64encode(data.vault_kv_secret_v2.cert[0].data["private_key"])
            }
          )
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

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-traefik.hcl"
  content = file("./podman-traefik/service.hcl")
}
