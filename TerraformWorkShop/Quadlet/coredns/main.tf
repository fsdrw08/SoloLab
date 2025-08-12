# load cert from local tls
data "terraform_remote_state" "root_ca" {
  count   = var.podman_kube.helm.secrets.tfstate == null ? 0 : 1
  backend = var.podman_kube.helm.secrets.tfstate.backend.type
  config  = var.podman_kube.helm.secrets.tfstate.backend.config
}

locals {
  cert = var.podman_kube.helm.secrets.tfstate == null ? null : [
    for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
    if cert.name == var.podman_kube.helm.secrets.tfstate.cert_name
  ]
}

data "helm_template" "podman_kube" {
  name  = var.podman_kube.helm.name
  chart = var.podman_kube.helm.chart

  values = [
    "${file(var.podman_kube.helm.value_file)}"
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
  #   for_each = var.podman_kube.helm.secrets == null ? [] : flatten([var.podman_kube.helm.secrets.value_sets])
  #   content {
  #     name  = set.value.name
  #     value = local.cert[0][set.value.value_ref_key]
  #   }
  # }

  # v3 helm provider
  set = flatten([
    var.podman_kube.helm.value_sets == null ? [] : [
      for value_set in flatten([var.podman_kube.helm.value_sets]) : {
        name = value_set.name
        value = value_set.value_string != null ? value_set.value_string : templatefile(
          "${value_set.value_template_path}", "${value_set.value_template_vars}"
        )
      }
    ],
    var.podman_kube.helm.secrets == null ? [] : [
      for value_set in flatten([var.podman_kube.helm.secrets.value_sets]) : {
        name  = value_set.name
        value = local.cert[0][value_set.value_ref_key]
        # value = data.vault_kv_secret_v2.cert[0].data[value_set.value_ref_key]
      }
    ],
  ])
}

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.manifest_dest_path
  content = data.helm_template.podman_kube.manifest
}

# # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
module "podman_quadlet" {
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
#   #     "sudo rm -f ${self.triggers.file_source}/traefik",
#   #   ]
#   # }
# }
