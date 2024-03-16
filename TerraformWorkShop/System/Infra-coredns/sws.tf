resource "null_resource" "sws_init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/sws"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/sws"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/sws/init.sh", {
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

module "sws" {
  depends_on = [module.coredns]
  source     = "../modules/sws"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  runas = {
    take_charge = false
    user        = "vyos"
    group       = "users"
  }
  install = {
    tar_file_source   = "https://github.com/static-web-server/static-web-server/releases/download/v2.28.0/static-web-server-v2.28.0-x86_64-unknown-linux-gnu.tar.gz"
    tar_file_path     = "/home/vyos/static-web-server-v2.28.0-x86_64-unknown-linux-gnu.tar.gz"
    tar_file_bin_path = "static-web-server-v2.28.0-x86_64-unknown-linux-gnu/static-web-server"
    bin_file_dir      = "/usr/local/bin"
  }
  config = {
    main = {
      basename = "static-web-server.toml"
      content = templatefile("./sws/static-web-server_non_socket.toml", {
        SERVER_HOST                      = "192.168.255.2"
        SERVER_PORT                      = "4433"
        SERVER_ROOT                      = "/mnt/data/sws"
        SERVER_LOG_LEVEL                 = "warn"
        SERVER_HTTP2_TLS                 = true
        SERVER_HTTP2_TLS_CERT            = "/etc/sws/certs/server.crt"
        SERVER_HTTP2_TLS_KEY             = "/etc/sws/certs/server.key"
        SERVER_HTTPS_REDIRECT            = true
        SERVER_HTTPS_REDIRECT_HOST       = "sws.service.consul"
        SERVER_HTTPS_REDIRECT_FROM_PORT  = "4080"
        SERVER_HTTPS_REDIRECT_FROM_HOSTS = "sws.service.consul"
        SERVER_DIRECTORY_LISTING         = "true"
        SERVER_DIRECTORY_LISTING_ORDER   = "0"
      })
    }
    tls = {
      cert_basename = "server.crt"
      cert_content = format("%s\n%s", lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "sws", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem
      )
      key_basename = "server.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "sws", null)
      sub_dir      = "certs"
    }
    dir = "/etc/sws"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      content = templatefile("${path.root}/sws/static-web-server_non_socket.service", {
        user               = "vyos"
        group              = "users"
        SERVER_CONFIG_FILE = "/etc/sws/static-web-server.toml"
      })
      target_path = "/etc/systemd/system/sws.service"
    }
  }
}
