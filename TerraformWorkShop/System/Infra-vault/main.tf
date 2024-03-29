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
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

resource "system_file" "init" {
  depends_on = [null_resource.init]
  path       = "/home/vyos/Init-Vault.sh"
  content = templatefile("${path.root}/vault/Init-Vault.sh", {
    VAULT_ADDR                       = "https://127.0.0.1:8200"
    VAULT_CACERT                     = "/etc/vault.d/tls/ca.crt"
    VAULT_OPERATOR_SECRETS_JSON_PATH = "/mnt/data/vault/init/vault_operator_secrets.json"
  })
  user  = "vyos"
  group = "users"
  mode  = "700"
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
    zip_file_source = "http://sws.infra.sololab:4080/releases/vault%5F1.15.6%5Flinux%5Famd64.zip"
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
    main = {
      basename = "vault.hcl"
      content = templatefile("${path.root}/vault/vault.hcl", {
        storage_path                   = "/opt/vault/data"
        node_id                        = "raft_node_1"
        listener_address               = "{{ GetInterfaceIP `eth2` }}:8200"
        listener_cluster_address       = "{{ GetInterfaceIP `eth2` }}:8201"
        listener_local_address         = "127.0.0.1:8200"
        listener_local_cluster_address = "127.0.0.1:8201"
        # https://discuss.hashicorp.com/t/unable-to-init-vault-raft/49119
        # Since using TLS, need to add https in the cluster_addr and api_addr values.
        api_addr                 = "https://vault.infra.sololab:8200"
        cluster_addr             = "https://vault.infra.sololab:8201"
        tls_ca_file              = "/etc/vault.d/tls/ca.crt"
        tls_cert_file            = "/etc/vault.d/tls/server.crt"
        tls_key_file             = "/etc/vault.d/tls/server.key"
        tls_disable_client_certs = "true"
      })
    }
    tls = {
      ca_basename   = "ca.crt"
      ca_content    = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      cert_basename = "server.crt"
      cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "vault", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem,
        # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      ])
      key_basename = "server.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "vault", null)
      sub_dir      = "tls"
    }
    env = {
      basename = "vault.env"
      content = templatefile("${path.root}/vault/vault.env", {
        VAULT_ADDR                       = "https://127.0.0.1:8200"
        VAULT_CACERT                     = "/etc/vault.d/tls/ca.crt"
        VAULT_OPERATOR_SECRETS_JSON_PATH = "/mnt/data/vault/init/vault_operator_secrets.json"
      })
    }
    dir = "/etc/vault.d"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_service_unit = {
      path = "/usr/lib/systemd/system/vault.service"
      content = templatefile("${path.root}/vault/vault.service", {
        user             = "vyos"
        group            = "users"
        post_script_path = system_file.init.path
      })
    }
  }
}

module "vault_restart" {
  depends_on = [module.vault]
  source     = "../modules/systemd_path"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  systemd_path_unit = {
    content = templatefile("${path.root}/vault/restart.path", {
      PathModified = [
        "/etc/vault.d/vault.hcl",
        "/etc/vault.d/tls/server.crt",
        "/etc/vault.d/tls/server.key"
      ]
    })
    path = "/usr/lib/systemd/system/vault_restart.path"
  }
  systemd_service_unit = {
    content = templatefile("${path.root}/vault/restart.service", {
      AssertPathExists = "/lib/systemd/system/vault.service"
      target_service   = "vault.service"
    })
    path = "/usr/lib/systemd/system/vault_restart.service"
  }
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

resource "system_file" "snippet" {
  depends_on = [module.vault]
  # https://coredns.io/plugins/auto/#:~:text=is%20the%20second.-,The%20default%20is%3A,example.com,-.
  path = "/etc/coredns/snippets/vault_dns.conf"
  # content = file("${path.root}/sws/sws.conf")
  content = templatefile("${path.root}/vault/vault_dns.conf", {
    IP   = "192.168.255.2"
    FQDN = "vault.infra.sololab"
  })
}

locals {
  vault_post_process = {
    New-VaultStaticToken = {
      script_path = "./vault/New-VaultStaticToken.sh"
      vars = {
        ENV_FILE     = "/etc/vault.d/vault.env"
        STATIC_TOKEN = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
      }
    }
  }
}

resource "null_resource" "vault_post_process" {
  depends_on = [module.vault]
  for_each   = local.vault_post_process
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
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -f ${self.triggers.file_source}/consul",
  #   ]
  # }
}
