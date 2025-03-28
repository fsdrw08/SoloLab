resource "random_uuid" "uuid" {
}

data "helm_template" "podman_kube" {
  name  = var.podman_kube.helm.name
  chart = var.podman_kube.helm.chart

  values = [
    "${file(var.podman_kube.helm.values)}"
  ]

  dynamic "set" {
    for_each = var.podman_kube.helm.set == null ? [] : var.podman_kube.helm.set
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
  set {
    name  = "ceph.config.global.fsid"
    value = random_uuid.uuid.result
  }
}

resource "remote_file" "podman_kube" {
  path    = var.podman_kube.manifest_dest_path
  content = data.helm_template.podman_kube.manifest
  conn {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = sensitive(var.vm_conn.password)
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

resource "null_resource" "podman_quadlet" {
  depends_on = [
    remote_file.podman_kube,
    remote_file.podman_quadlet
  ]
  triggers = {
    service_name = var.podman_quadlet.service.name
    quadlet_md5  = md5(join("\n", [for quadlet in remote_file.podman_quadlet : quadlet.content]))
    host         = var.vm_conn.host
    port         = var.vm_conn.port
    user         = var.vm_conn.user
    password     = sensitive(var.vm_conn.password)
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
      "systemctl --user daemon-reload",
      "systemctl --user ${var.podman_quadlet.service.status} ${self.triggers.service_name}",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user stop ${self.triggers.service_name}",
    ]
  }
}

module "container_restart" {
  depends_on = [null_resource.podman_quadlet]
  source     = "../../System/modules/systemd_path_user"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  systemd_path_unit = {
    content = templatefile(
      var.container_restart.systemd_path_unit.content.templatefile,
      var.container_restart.systemd_path_unit.content.vars
    )
    path = var.container_restart.systemd_path_unit.path
  }
  systemd_service_unit = {
    content = templatefile(
      var.container_restart.systemd_service_unit.content.templatefile,
      var.container_restart.systemd_service_unit.content.vars
    )
    path = var.container_restart.systemd_service_unit.path
  }
}

# resource "vyos_static_host_mapping" "host_mapping" {
#   depends_on = [
#     null_resource.podman_quadlet,
#   ]
#   host = "consul.day0.sololab"
#   ip   = "192.168.255.20"
# }

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
#   #     "sudo rm -f ${self.triggers.file_source}/consul",
#   #   ]
#   # }
# }
