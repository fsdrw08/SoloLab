resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/vault/init.sh", {
        dirs        = "/mnt/data/vault/data /mnt/data/vault/tls"
        chown_user  = "vyos"
        chown_group = "users"
        chown_dir   = "/mnt/data/vault"
      })
    ]
  }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../RootCA/terraform.tfstate"
  }
}

resource "system_file" "cert" {
  depends_on = [null_resource.init]
  path       = "/mnt/data/vault/tls/tls.crt"
  # https://discuss.hashicorp.com/t/transforming-a-list-of-objects-to-a-map/25373
  # content = lookup((merge(data.terraform_remote_state.root_ca.outputs.signed_cert_pem...)), each.key, null) #.cert_pem
  content = lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "vault", null)
}

resource "system_file" "key" {
  depends_on = [null_resource.init]
  path       = "/mnt/data/vault/tls/tls.key"
  content    = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "vault", null)
}

module "vault" {
  depends_on = [
    null_resource.init,
    system_file.cert,
    system_file.key
  ]
  source = "../modules/vault"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    zip_file_source = "https://releases.hashicorp.com/vault/1.15.5/vault_1.15.5_linux_amd64.zip"
    zip_file_path   = "/home/vyos/vault.zip"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    user  = "vyos"
    group = "users"
  }
  storage = {
    dir_target = "/mnt/data/vault"
    dir_link   = "/opt/vault"
  }
  config = {
    file_source = "${path.root}/vault/vault.hcl"
    vars = {
      storage_path             = "/opt/vault/data"
      node_id                  = "raft_node_1"
      api_addr                 = "https://vault.service.consul:8200"
      cluster_addr             = "https://vault.service.consul:8201"
      listener_address         = "127.0.0.1:8200"
      tls_cert_file            = "/opt/vault/tls/tls.crt"
      tls_key_file             = "/opt/vault/tls/tls.key"
      tls_disable_client_certs = "true"
    }
    file_path_dir = "/etc/vault.d"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      file_source = "${path.root}/vault/vault.service"
      vars = {
        user  = "vyos"
        group = "users"
      }
      file_path = "/etc/systemd/system/vault.service"
    }
  }
}

resource "system_file" "vault_consul" {
  depends_on = [
    module.vault,
  ]
  path    = "/etc/consul.d/vault.hcl"
  content = file("${path.root}/vault/vault_consul.hcl")
  user    = "vyos"
  group   = "users"
}
