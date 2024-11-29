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
    path = var.cert_config.tfstate_ref
  }
}

resource "system_folder" "ssl_dir" {
  path = var.cert_config.host_path
  uid  = var.runas.uid
  gid  = var.runas.gid
}

resource "system_file" "ssl_cert" {
  depends_on = [system_folder.ssl_dir]
  path       = "${var.cert_config.host_path}/tls.crt"
  content = join("", [
    lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), var.cert_config.tfstate_tls_entity, null),
    data.terraform_remote_state.root_ca.outputs.int_ca_pem
  ])
  uid = var.runas.uid
  gid = var.runas.gid
}

resource "system_file" "ssl_key" {
  depends_on = [system_folder.ssl_dir]
  path       = "${var.cert_config.host_path}/tls.key"
  content    = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), var.cert_config.tfstate_tls_entity, null)
  uid        = var.runas.uid
  gid        = var.runas.gid
}

module "vyos_container" {
  depends_on = [
    null_resource.init,
    system_file.ssl_cert,
    system_file.ssl_key,
  ]
  source   = "../../modules/vyos-container"
  vm_conn  = var.vm_conn
  network  = var.container.network
  workload = var.container.workload
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
    # module.vyos_container_adminer
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
