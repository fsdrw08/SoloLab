resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
  triggers = {
    dirs = "/home/podmgr/traefik-file-provider"
  }
  provisioner "remote-exec" {
    inline = [
      "[ -d ${self.triggers.dirs} ] || mkdir -p ${self.triggers.dirs}"
    ]
  }
}

# load cert from vault
data "vault_kv_secret_v2" "cert" {
  count = var.podman_kube.helm.secrets.vault_kvv2 == null ? 0 : 1
  mount = var.podman_kube.helm.secrets.vault_kvv2.mount
  name  = var.podman_kube.helm.secrets.vault_kvv2.name
}

# load cert from local tls
# data "terraform_remote_state" "root_ca" {
#   count   = var.podman_kube.helm.secrets.tfstate == null ? 0 : 1
#   backend = var.podman_kube.helm.secrets.tfstate.backend.type
#   config  = var.podman_kube.helm.secrets.tfstate.backend.config
# }

# locals {
#   cert = var.podman_kube.helm.secrets.tfstate == null ? null : [
#     for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
#     if cert.name == var.podman_kube.helm.secrets.tfstate.cert_name
#   ]
# }

data "helm_template" "podman_kube" {
  name  = var.podman_kube.helm.name
  chart = var.podman_kube.helm.chart

  values = [
    "${file(var.podman_kube.helm.value_file)}"
  ]

  # v2 helm provider
  # normal values
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
        name = value_set.name
        # value = local.cert[0][value_set.value_ref_key]
        value = data.vault_kv_secret_v2.cert[0].data[value_set.value_ref_key]
      }
    ],
  ])
}

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.manifest_dest_path
  content = data.helm_template.podman_kube.manifest
}

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

# resource "remote_file" "traefik_file_provider" {
#   depends_on = [null_resource.init]
#   path       = "/var/home/podmgr/traefik-file-provider/traefik.traefik.yaml"
#   content    = file("./attachments/traefik.traefik.yaml")
# }

resource "remote_file" "consul_service" {
  for_each = toset([
    "./attachments/traefik.consul.hcl",
  ])
  path    = "/var/home/podmgr/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
