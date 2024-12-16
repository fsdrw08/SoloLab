resource "null_resource" "init" {
  triggers = {
    host      = var.vm_conn.host
    port      = var.vm_conn.port
    user      = var.vm_conn.user
    password  = var.vm_conn.password
    uid       = var.runas.uid
    gid       = var.runas.gid
    data_dirs = var.data_dirs
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
      <<-EOT
        #!/bin/bash
        sudo mkdir -p ${var.data_dirs}
        sudo chown ${var.runas.uid}:${var.runas.gid} ${var.data_dirs}
      EOT
    ]
  }
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -rf ${self.triggers.data_dirs}",
  #   ]
  # }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = var.certs.cert_content_tfstate_ref
  }
}

resource "system_folder" "config" {
  path = var.config.dir
  uid  = var.runas.uid
  gid  = var.runas.gid
}

resource "system_file" "config" {
  depends_on = [system_folder.config]
  for_each = var.config.files == null ? {} : {
    for file in var.config.files : file.basename => file
  }
  path    = "${system_folder.config.path}/${each.value.basename}"
  content = each.value.content
  uid     = var.runas.uid
  gid     = var.runas.gid
}

resource "system_file" "entry_script" {
  depends_on = [system_folder.config]
  path       = "${system_folder.config.path}/entrypoint.sh"
  content    = var.config.entry_script
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = 755
}

# resource "system_folder" "certs" {
#   depends_on = [system_folder.config]
#   path       = var.certs.dir
#   uid        = var.runas.uid
#   gid        = var.runas.gid
# }

# resource "system_file" "cert" {
#   depends_on = [system_folder.certs]
#   path       = "${system_folder.certs.path}/tls.crt"
#   content = join("", [
#     lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), var.certs.cert_content_tfstate_entity, null),
#     data.terraform_remote_state.root_ca.outputs.int_ca_pem
#   ])
#   uid  = var.runas.uid
#   gid  = var.runas.gid
#   mode = 600
# }

# resource "system_file" "key" {
#   depends_on = [system_folder.certs]
#   path       = "${system_folder.certs.path}/tls.key"
#   content    = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), var.certs.cert_content_tfstate_entity, null)
#   uid        = var.runas.uid
#   gid        = var.runas.gid
#   mode       = 600
# }

module "vyos_container" {
  depends_on = [
    null_resource.init,
    system_file.config,
    system_file.entry_script,
    # system_file.cert,
    # system_file.key,
  ]
  source   = "../../modules/vyos-container"
  vm_conn  = var.vm_conn
  network  = var.container.network
  workload = var.container.workload
}

resource "vyos_config_block_tree" "pki" {
  path = "pki certificate ${var.certs.cert_content_tfstate_entity}"
  configs = {
    "certificate" = join("",
      slice(
        split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_cert_pem, var.certs.cert_content_tfstate_entity, null)),
        1,
        length(
          split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_cert_pem, var.certs.cert_content_tfstate_entity, null))
        ) - 2
      )
    )
    "private key" = join("",
      slice(
        split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_key_pkcs8, var.certs.cert_content_tfstate_entity, null)),
        1,
        length(
          split("\n", lookup(data.terraform_remote_state.root_ca.outputs.signed_key_pkcs8, var.certs.cert_content_tfstate_entity, null))
        ) - 2
      )
    )
  }
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
    vyos_config_block_tree.pki
  ]
  for_each = var.reverse_proxy
  path     = each.value.path
  configs  = each.value.configs
}

resource "vyos_static_host_mapping" "host_mappings" {
  depends_on = [
    module.vyos_container,
    vyos_config_block_tree.reverse_proxy,
  ]
  for_each = {
    for dns_record in var.dns_records : dns_record.host => dns_record
  }
  host = each.value.host
  ip   = each.value.ip
}

resource "vyos_config_block_tree" "dns_forwarding" {
  depends_on = [
    module.vyos_container,
  ]
  path    = var.dns_forwarding.path
  configs = var.dns_forwarding.configs
}
