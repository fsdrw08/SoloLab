module "http_socket_activation" {
  source = "../../modules/system-systemd_unit_user"
  vm_conn = {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
  systemd_unit_files = [
    {
      content = templatefile(
        "./podman-traefik/http.socket",
        {
          name = "traefik-container"
        }
      )
      path = "/home/podmgr/.config/systemd/user/http.socket"
    }
  ]
  systemd_unit_name = "http.socket"
}

module "https_socket_activation" {
  source = "../../modules/system-systemd_unit_user"
  vm_conn = {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
  systemd_unit_files = [
    {
      content = templatefile(
        "./podman-traefik/https.socket",
        {
          name = "traefik-container"
        }
      )
      path = "/home/podmgr/.config/systemd/user/https.socket"
    }
  ]
  systemd_unit_name = "http.socket"
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

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.manifest_dest_path
  content = data.helm_template.podman_kube.manifest
}

# # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
resource "remote_file" "podman_quadlet" {
  depends_on = [remote_file.podman_kube]
  for_each = {
    for content in var.podman_quadlet.quadlet.file_contents : content.file_source => content
  }
  path = join("/", [
    var.podman_quadlet.quadlet.file_path_dir,
    basename("${each.value.file_source}")
  ])
  content = templatefile(
    each.value.file_source,
    each.value.vars
  )
}

module "podman_quadlet" {
  depends_on = [
    remote_file.podman_kube,
    module.http_socket_activation,
    module.https_socket_activation,
  ]
  source         = "../../modules/system-systemd_quadlet"
  vm_conn        = var.prov_remote
  podman_quadlet = var.podman_quadlet
}

module "container_restart" {
  depends_on = [module.podman_quadlet]
  source     = "../../modules/system-systemd_unit_user"
  vm_conn = {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
  systemd_unit_files = [
    for file in var.container_restart.systemd_unit_files :
    {
      content = templatefile(
        file.content.templatefile,
        file.content.vars
      )
      path = file.path
    }
  ]
  systemd_unit_name = var.container_restart.systemd_unit_name
}

resource "powerdns_record" "record" {
  zone    = var.dns_record.zone
  name    = var.dns_record.name
  type    = var.dns_record.type
  ttl     = var.dns_record.ttl
  records = var.dns_record.records
}

