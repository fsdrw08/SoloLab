data "terraform_remote_state" "root_ca" {
  count   = var.podman_kube.helm.tls_value_sets.value_ref.tfstate == null ? 0 : 1
  backend = var.podman_kube.helm.tls_value_sets.value_ref.tfstate.backend
  config  = var.podman_kube.helm.tls_value_sets.value_ref.tfstate.config
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
    for_each = var.podman_kube.helm.tls_value_sets == null ? [] : [
      # ca
      tomap({
        "name"  = var.podman_kube.helm.tls_value_sets.name.ca,
        "value" = data.terraform_remote_state.root_ca[0].outputs.int_ca_pem
      }),
      # cert
      tomap({
        "name" = var.podman_kube.helm.tls_value_sets.name.cert,
        "value" = join("", [
          lookup((data.terraform_remote_state.root_ca[0].outputs.signed_cert_pem), var.podman_kube.helm.tls_value_sets.value_ref.tfstate.entity, null),
          data.terraform_remote_state.root_ca[0].outputs.int_ca_pem,
        ])
      }),
      # key
      tomap({
        "name"  = var.podman_kube.helm.tls_value_sets.name.private_key,
        "value" = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_key), var.podman_kube.helm.tls_value_sets.value_ref.tfstate.entity, null)
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

module "podman_quadlet" {
  depends_on     = [remote_file.podman_kube]
  source         = "../../modules/system-systemd_quadlet"
  vm_conn        = var.prov_remote
  podman_quadlet = var.podman_quadlet
}

# https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
# resource "remote_file" "podman_quadlet" {
#   depends_on = [remote_file.podman_kube]
#   for_each = {
#     for content in var.podman_quadlet.quadlet.file_contents : content.file_source => content
#   }
#   # path = format("${var.podman_quadlet.quadlet.file_path_dir}/%s", basename("${each.value.file_source}"))
#   path = join("/", [
#     var.podman_quadlet.quadlet.file_path_dir,
#     basename("${each.value.file_source}")
#   ])
#   content = templatefile(
#     each.value.file_source,
#     each.value.vars
#   )
#   # why not put remote-exec provision with when destroy run "systemctl --user daemon-reload" here?
#   # ref https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#destroy-time-provisioners
#   # Destroy provisioners are run *before* the resource is destroyed
#   # in order to remove the service which generate by quadlet here, the process should be:
#   # remove the quadlet file first, then run "systemctl --user daemon-reload"
#   # that's why we need add depends_on = [remote_file.podman_kube] in this resource
#   # and add provisioner step run "systemctl --user daemon-reload" when destroy in resource "remote_file.podman_kube"
# }

# resource "null_resource" "podman_quadlet" {
#   depends_on = [
#     remote_file.podman_kube,
#     remote_file.podman_quadlet
#   ]
#   triggers = {
#     service_name = var.podman_quadlet.service.name
#     quadlet_md5  = md5(join("\n", [for quadlet in remote_file.podman_quadlet : quadlet.content]))
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
#     inline = [
#       "systemctl --user daemon-reload",
#       "systemctl --user ${var.podman_quadlet.service.status} ${self.triggers.service_name}",
#     ]
#   }
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "systemctl --user stop ${self.triggers.service_name}",
#     ]
#   }
# }

module "container_restart" {
  depends_on = [module.podman_quadlet]
  source     = "../../modules/system-systemd_path_user"
  vm_conn = {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
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
  #     "sudo rm -f ${self.triggers.file_source}/consul",
  #   ]
  # }
}
