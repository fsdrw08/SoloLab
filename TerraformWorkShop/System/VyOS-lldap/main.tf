resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/lldap"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/lldap"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/lldap/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "lldap" {
  depends_on = [
    null_resource.init,
  ]
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
    main = {
      templatefile_path = "${path.root}/lldap/lldap_config.toml"
      templatefile_vars = {
        ldap_host       = "192.168.255.2"
        ldap_port       = "389"
        http_host       = "127.0.0.1"
        http_port       = "17170"
        http_url        = "https://lldap.service.consul"
        jwt_secret      = "REPLACE_WITH_RANDOM"
        ldap_base_dn    = "dc=root,dc=sololab"
        ldap_user_dn    = "admin"
        ldap_user_pass  = "P@ssw0rd"
        database_url    = "sqlite:///var/lib/lldap/users.db?mode=rwc"
        ldaps_enabled   = "true"
        ldaps_port      = "636"
        ldaps_cert_file = "/etc/lldap/tls/server.crt"
        ldaps_key_file  = "/etc/lldap/tls/server.key"
      }
    }
    tls = {
      cert_basename = "server.crt"
      cert_content = format("%s\n%s", lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "lldap", null),
        data.terraform_remote_state.root_ca.outputs.root_cert_pem
      )
      key_basename = "server.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "lldap", null)
      sub_dir      = "tls"
    }
    dir = "/etc/lldap"
  }
  storage = {
    dir_target = "/mnt/data/lldap"
    dir_link   = "/var/lib/lldap"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      templatefile_path = "${path.root}/lldap/lldap.service"
      templatefile_vars = {
        user                 = "vyos"
        group                = "users"
        WorkingDirectory     = "/usr/share/lldap"
        ReadWriteDirectories = "/var/lib/lldap"
      }
      target_path = "/lib/systemd/system/lldap.service"
    }
  }
}

resource "system_file" "lldap_consul" {
  depends_on = [
    module.lldap,
  ]
  path    = "/etc/consul.d/lldap_consul.hcl"
  content = file("${path.root}/lldap/lldap_consul.hcl")
  user    = "vyos"
  group   = "users"
}
