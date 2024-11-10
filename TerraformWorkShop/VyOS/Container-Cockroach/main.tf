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

module "config_map" {
  source  = "../../modules/system-cockroachdb"
  vm_conn = var.vm_conn
  install = null
  runas   = var.runas
  config = {
    certs = {
      # https://www.cockroachlabs.com/docs/stable/authentication
      ca_cert_content = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      node_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_node_1", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem
      ])
      node_key_content     = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_node_1", null)
      client_cert_basename = "client.root.crt"
      client_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_client_root", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem
      ])
      client_key_basename = "client.root.key"
      client_key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_client_root", null)
      sub_dir             = "certs"
    }
    dir = "/etc/cockroach"
  }
}

module "vyos_container" {
  depends_on = [
    null_resource.init,
    module.config_map
  ]
  source   = "../../modules/vyos-container"
  vm_conn  = var.vm_conn
  network  = var.container.network
  workload = var.container.workload
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [module.vyos_container]
  for_each   = var.reverse_proxy
  path       = each.value.path
  configs    = each.value.configs
}

resource "vyos_static_host_mapping" "host_mapping" {
  depends_on = [
    module.vyos_container,
    vyos_config_block_tree.reverse_proxy,
  ]
  host = var.dns_record.host
  ip   = var.dns_record.ip
}

locals {
  cockroach_post_process = {
    Set-TerraformBackend = {
      script_path = "${path.root}/Set-TerraformBackend.sh"
      vars = {
        container_name = "cockroach"
        certs_dir      = "/certs/"
        listen_addr    = "127.0.0.1:5432"
      }
    }
  }
}

resource "null_resource" "post_process" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = local.cockroach_post_process
  triggers = {
    script_content = sha256(templatefile("${each.value.script_path}", "${each.value.vars}"))
    host           = var.vm_conn.host
    port           = var.vm_conn.port
    user           = var.vm_conn.user
    password       = sensitive(var.vm_conn.password)
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
}
