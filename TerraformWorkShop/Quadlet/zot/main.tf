data "terraform_remote_state" "root_ca" {
  count   = var.podman_kube.helm.tls.tfstate == null ? 0 : 1
  backend = var.podman_kube.helm.tls.tfstate.backend.type
  config  = var.podman_kube.helm.tls.tfstate.backend.config
}

locals {
  cert = var.podman_kube.helm.tls.tfstate == null ? null : [
    for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
    if cert.name == var.podman_kube.helm.tls.tfstate.cert_name
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
    for_each = var.podman_kube.helm.tls == null ? [] : flatten([var.podman_kube.helm.tls.value_sets])
    content {
      name  = set.value.name
      value = local.cert[0][set.value.value_ref_key]
    }
  }
}

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.manifest_dest_path
  content = data.helm_template.podman_kube.manifest
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

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-zot.hcl"
  content = file("./podman-zot/service.hcl")
}
