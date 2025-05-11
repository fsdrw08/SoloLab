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

data "terraform_remote_state" "root_ca" {
  count   = var.podman_kube.helm.tls.tfstate == null ? 0 : 1
  backend = var.podman_kube.helm.tls.tfstate.backend.type
  config  = var.podman_kube.helm.tls.tfstate.backend.config
}

locals {
  # cert = var.podman_kube.helm.tls.tfstate == null ? null : flatten([
  #   for cert_name in ["pdns-auth", "traefik"] : [
  #     for cert in data.terraform_remote_state.root_ca[0].outputs.signed_certs : cert
  #     if cert.name == cert_name
  #     # if cert.name == var.podman_kube.helm.tls.tfstate.cert_name
  #   ]
  # ])
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
    # remote_file.podman_quadlet,
    # remote_file.http_socket,
    # remote_file.https_socket,
    # null_resource.service_stop
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

resource "remote_file" "consul_service" {
  path    = "/var/home/podmgr/consul-services/service-traefik.hcl"
  content = file("./podman-traefik/service.hcl")
}
