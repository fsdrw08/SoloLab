data "terraform_remote_state" "root_ca" {
  count   = var.certs_ref == null ? 0 : 1
  backend = var.certs_ref.tfstate.backend
  config  = var.certs_ref.tfstate.config
}

data "helm_template" "podman_kube" {
  name  = var.podman_kube.helm.name
  chart = var.podman_kube.helm.chart

  values = [
    "${file(var.podman_kube.helm.values)}"
  ]

  set {
    name = var.certs_ref.config_node.cert
    value = join("", [
      lookup((data.terraform_remote_state.root_ca[0].outputs.signed_cert_pem), var.certs_ref.tfstate.entity, null),
      data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
    ])
  }
  set {
    name  = var.certs_ref.config_node.key
    value = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_key), var.certs_ref.tfstate.entity, null)
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

# resource "vyos_static_host_mapping" "host_mapping" {
#   depends_on = [
#     null_resource.podman_quadlet,
#   ]
#   host = "traefik.day0.sololab"
#   ip   = "192.168.255.20"
# }

locals {
  post_process = {
    Add-EtcdUser = {
      script_path = "./podman-etcd/Add-EtcdUser.sh"
      vars = {
        CONTAINER_NAME = "etcd-etcd"
        ENDPOINTS      = "unix://localhost:0"
        ROOT_PASSWORD  = "P@ssw0rd"
      }
    }
  }
}

resource "null_resource" "post_process" {
  depends_on = [module.podman_quadlet]
  for_each   = local.post_process
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
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -f ${self.triggers.file_source}/traefik",
  #   ]
  # }
}
