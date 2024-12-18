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
  count   = var.certs == null ? 0 : 1
  backend = "local"
  config = {
    path = var.certs.cert_content_tfstate_ref
  }
}

locals {
  certs = var.certs == null ? null : {
    cacert_basename = var.certs.cacert_basename
    cacert_content  = data.terraform_remote_state.root_ca[0].outputs.root_cert_pem
    cert_basename   = var.certs.cert_basename
    cert_content = join("", [
      lookup((data.terraform_remote_state.root_ca[0].outputs.signed_cert_pem), var.certs.cert_content_tfstate_entity, null),
      data.terraform_remote_state.root_ca[0].outputs.int_ca_pem
    ])
    key_basename = var.certs.key_basename
    key_content  = lookup((data.terraform_remote_state.root_ca[0].outputs.signed_key), var.certs.cert_content_tfstate_entity, null)
    dir          = var.certs.dir
  }
}

# zot config
module "config_map" {
  source  = "../../modules/system-zot"
  vm_conn = var.vm_conn
  runas   = var.runas
  install = {
    server = null
    # client = {
    #   bin_file_dir = "/usr/bin"
    #   # https://github.com/project-zot/zot/releases
    #   bin_file_source = "http://files.day0.sololab/bin/zli-linux-amd64"
    # }
    # oras = {
    #   # https://github.com/oras-project/oras/releases
    #   tar_file_source = "http://files.day0.sololab/bin/oras_1.2.0_linux_amd64.tar.gz"
    #   tar_file_path   = "/home/vyos/oras_1.2.0_linux_amd64.tar.gz"
    #   bin_file_dir    = "/usr/local/bin"
    # }
  }
  config = {
    # https://zotregistry.dev/v2.0.4/admin-guide/admin-configuration/#configuration-file
    basename = var.config.basename
    content  = jsonencode(yamldecode(file("${path.module}/${var.config.content_yaml}")))
    dir      = var.config.dir
  }
  certs = local.certs
}

# for ldap auth
# To allow for separation of configuration and credentials, 
# the credentials for the LDAP server are specified in a separate file, as shown in the following example.
# resource "system_file" "ldap_credential" {
#   depends_on = module.config_map[]
#   path       = "/etc/zot/config-ldap-credentials.json"
#   content = jsonencode({
#     bindDN       = "uid=readonly,ou=Services,dc=root,dc=sololab"
#     bindPassword = "P@ssw0rd"
#   })
#   uid = var.runas.uid
#   gid = var.runas.gid
# }

# for htpasswd auth
resource "htpasswd_password" "htpasswd" {
  password = "P@ssw0rd"
}

resource "system_file" "htpasswd" {
  depends_on = [module.config_map]
  path       = "/etc/zot/htpasswd"
  content    = "admin:${htpasswd_password.htpasswd.bcrypt}"
  uid        = var.runas.uid
  gid        = var.runas.gid
}

module "vyos_container" {
  depends_on = [module.config_map]
  source     = "../../modules/vyos-container"
  vm_conn    = var.vm_conn
  network    = var.container.network
  workload   = var.container.workload
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
