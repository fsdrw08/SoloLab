resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/vault/data /mnt/data/vault/tls /mnt/data/vault/init"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/vault"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/vault/init.sh", {
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
    path = "../../RootCA/terraform.tfstate"
  }
}

resource "system_file" "init" {
  depends_on = [null_resource.init]
  path       = "/home/vyos/Init-Vault.sh"
  content = templatefile("${path.root}/vault/Init-Vault.sh", {
    VAULT_ADDR                       = "https://vault.service.consul"
    CA_CERTIFICATE                   = "/etc/vault.d/ca.crt"
    VAULT_OPERATOR_SECRETS_JSON_PATH = "/mnt/data/vault/init/vault_operator_secrets.json"
  })
}

module "vault" {
  depends_on = [
    null_resource.init,
    system_file.init
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
      raft_leader_ca_cert_file = "/etc/vault.d/ca.crt"
      listener_address         = "127.0.0.1:8200"
      listener_cluster_address = "{{ GetInterfaceIP `eth2` }}:8201"
      # https://discuss.hashicorp.com/t/unable-to-init-vault-raft/49119
      api_addr                 = "https://vault.service.consul"
      cluster_addr             = "https://vyos-lts.node.consul:8201"
      tls_cert_file            = "/etc/vault.d/server.crt"
      tls_key_file             = "/etc/vault.d/server.key"
      tls_disable_client_certs = "true"
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
      file_path = "/usr/lib/systemd/system/vault.service"
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
