# resource "null_resource" "init" {
#   connection {
#     type     = "ssh"
#     host     = var.vm_conn.host
#     port     = var.vm_conn.port
#     user     = var.vm_conn.user
#     password = var.vm_conn.password
#   }
#   triggers = {
#     dirs        = "/mnt/data/vault/data /mnt/data/vault/tls /mnt/data/vault/init"
#     chown_user  = "vyos"
#     chown_group = "users"
#     chown_dir   = "/mnt/data/vault"
#   }
#   provisioner "remote-exec" {
#     inline = [
#       templatefile("${path.root}/vault/init.sh", {
#         dirs        = self.triggers.dirs
#         chown_user  = self.triggers.chown_user
#         chown_group = self.triggers.chown_group
#         chown_dir   = self.triggers.chown_dir
#       })
#     ]
#   }
# }

# data "terraform_remote_state" "root_ca" {
#   backend = "local"
#   config = {
#     path = "../../TLS/RootCA/terraform.tfstate"
#   }
# }

# resource "system_file" "init" {
#   depends_on = [null_resource.init]
#   path       = "/home/vyos/Init-Vault.sh"
#   content = templatefile("${path.root}/vault/Init-Vault.sh", {
#     VAULT_ADDR                       = "https://vault.service.consul"
#     VAULT_CACERT                     = "/etc/lldap/tls/ca.crt"
#     VAULT_OPERATOR_SECRETS_JSON_PATH = "/mnt/data/vault/init/vault_operator_secrets.json"
#   })
# }

module "lldap" {
  # depends_on = [
  #   null_resource.init,
  #   system_file.init
  # ]
  source = "../modules/lldap"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    tar_file_source   = "https://github.com/lldap/lldap/releases/download/v0.5.0/amd64-lldap.tar.gz"
    tar_file_path     = "/home/vyos/amd64-lldap.tar.gz"
    tar_file_bin_path = "amd64-lldap/lldap"
    bin_file_dir      = "/usr/bin"
    tar_file_app_path = "amd64-lldap/app"
    app_pkg_dir       = "/usr/share/lldap/app"
  }
  runas = {
    user        = "vyos"
    group       = "users"
    take_charge = false
  }
  config = {
    templatefile_path = "${path.root}/lldap/lldap_config.toml"
    templatefile_vars = {
      ldap_host      = "192.168.255.2"
      ldap_port      = "3890"
      http_host      = "127.0.0.1"
      http_port      = "17170"
      http_url       = "https://lldap.service.consul"
      jwt_secret     = "REPLACE_WITH_RANDOM"
      ldap_base_dn   = "dc=root,dc=sololab"
      ldap_user_dn   = "admin"
      ldap_user_pass = "P@ssw0rd"
      ldaps_enabled  = "true"
      ldaps_port     = "6360"
    }
    tls = {
      ca_basename   = "ca.crt"
      ca_content    = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      cert_basename = "server.crt"
      cert_content = format("%s\n%s", lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "vault", null),
        data.terraform_remote_state.root_ca.outputs.root_cert_pem
      )
      key_basename = "server.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "vault", null)
      sub_dir      = "tls"
    }
    env_templatefile_path = "${path.root}/vault/vault.env"
    env_templatefile_vars = {
      VAULT_ADDR                       = "https://vault.service.consul"
      VAULT_CACERT                     = "/etc/lldap/ca.crt"
      VAULT_OPERATOR_SECRETS_JSON_PATH = "/mnt/data/vault/init/vault_operator_secrets.json"
    }
    dir = "/etc/lldap"
  }
  # storage = {
  #   dir_target = "/mnt/data/vault"
  #   dir_link   = "/opt/vault"
  # }
  # service = {
  #   status  = "started"
  #   enabled = true
  #   systemd_unit_service = {
  #     templatefile_path = "${path.root}/vault/vault.service"
  #     templatefile_vars = {
  #       user             = "vyos"
  #       group            = "users"
  #       post_script_path = system_file.init.path
  #     }
  #     target_path = "/usr/lib/systemd/system/vault.service"
  #   }
  # }
}

# resource "system_file" "vault_consul" {
#   depends_on = [
#     module.vault,
#   ]
#   path    = "/etc/consul.d/vault.hcl"
#   content = file("${path.root}/vault/vault_consul.hcl")
#   user    = "vyos"
#   group   = "users"
# }
