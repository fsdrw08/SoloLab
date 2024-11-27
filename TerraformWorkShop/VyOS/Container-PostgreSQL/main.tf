resource "null_resource" "init" {
  triggers = {
    host      = var.vm_conn.host
    port      = var.vm_conn.port
    user      = var.vm_conn.user
    password  = var.vm_conn.password
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
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "vyos_container_postgresql" {
  depends_on = [
    null_resource.init,
  ]
  source   = "../../modules/vyos-container"
  vm_conn  = var.vm_conn
  network  = var.container_postgresql.network
  workload = var.container_postgresql.workload
}

module "vyos_container_adminer" {
  depends_on = [
    null_resource.init,
    module.vyos_container_postgresql
  ]
  source   = "../../modules/vyos-container"
  vm_conn  = var.vm_conn
  network  = var.container_adminer.network
  workload = var.container_adminer.workload
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container_postgresql,
    module.vyos_container_adminer
  ]
  for_each = var.reverse_proxy
  path     = each.value.path
  configs  = each.value.configs
}

resource "vyos_static_host_mapping" "host_mappings" {
  depends_on = [
    module.vyos_container_postgresql,
    module.vyos_container_adminer,
    vyos_config_block_tree.reverse_proxy,
  ]
  for_each = {
    for dns_record in var.dns_records : dns_record.host => dns_record
  }
  host = each.value.host
  ip   = each.value.ip
}
