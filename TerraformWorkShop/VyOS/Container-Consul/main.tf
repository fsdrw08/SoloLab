resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    uid       = var.owner.uid
    gid       = var.owner.gid
    data_dirs = "/mnt/data/consul /mnt/data/consul-services"
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
        sudo mkdir -p ${self.triggers.data_dirs}
        sudo chown ${var.owner.uid}:${var.owner.gid} ${self.triggers.data_dirs}
      EOT
    ]
  }
}

data "vault_kv_secret_v2" "secrets" {
  for_each = {
    for secret in [
      {
        mount = "kvv2-certs"
        name  = "root"
      },
      {
        mount = "kvv2-consul"
        name  = "token-init_management"
      },
      {
        mount = "kvv2-consul"
        name  = "token-consul_dns"
      },
      {
        mount = "kvv2-consul"
        name  = "token-consul_client"
      },
      {
        mount = "kvv2-consul"
        name  = "key-gossip_encryption"
      },
    ] : secret.name => secret
  }
  mount = each.value.mount
  name  = each.value.name
}

# locals {
#   certs = [
#     for cert in data.vault_kv_secret_v2.cert.outputs.signed_certs : cert
#     if cert.name == "doh.vyos"
#   ]
# }

module "config_map" {
  depends_on = [null_resource.init]
  source     = "../../modules/system-config_files"
  owner = {
    uid = 100
    gid = 1000
  }
  config = {
    create_dir = true
    dir        = "/mnt/data/etc/consul"
    files = [
      {
        basename = "client.hcl"
        content = templatefile("./attachments/client.hcl", {
          # consul_token_init    = data.vault_kv_secret_v2.secrets["token-init_management"].data["token"]
          consul_token_default = data.vault_kv_secret_v2.secrets["token-consul_dns"].data["token"]
          consul_token_client  = data.vault_kv_secret_v2.secrets["token-consul_client"].data["token"]
          consul_encrypt_key   = data.vault_kv_secret_v2.secrets["key-gossip_encryption"].data["key"]
          tls_ca_file          = "/consul/config/certs/ca.crt"
          # tls_cert_file        = "/consul/config/certs/server.crt"
          # tls_key_file         = "/consul/config/certs/server.key"
        })
      }
    ]
    secrets = [
      {
        sub_dir = "certs"
        files = [
          {
            basename = "ca.crt"
            content  = data.vault_kv_secret_v2.secrets["root"].data["ca"]
          }
        ]
      }
    ]
  }
}

module "vyos_container" {
  depends_on = [
    null_resource.init,
    module.config_map
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  workloads = [
    {
      name      = "consul"
      image     = "zot.vyos.sololab.dev/hashicorp/consul:1.21.4"
      pull_flag = "--tls-verify=false"
      others = {
        "allow-host-networks"  = ""
        "arguments"            = "agent -config-dir /consul/services"
        "environment TZ value" = "Asia/Shanghai"

        "volume config source"       = "/mnt/data/etc/consul"
        "volume config destination"  = "/consul/config"
        "volume data source"         = "/mnt/data/consul"
        "volume data destination"    = "/consul/data"
        "volume service source"      = "/mnt/data/consul-services"
        "volume service destination" = "/consul/services"
      }
    }
  ]
}

# resource "vyos_config_block_tree" "reverse_proxy" {
#   depends_on = [
#     module.vyos_container,
#     # vyos_config_block_tree.pki
#   ]
#   for_each = {
#     l4_frontend = {
#       # when send doh request to doh server by ip address,
#       # it means no SNI information in the tcp request,
#       # have to set default backend for this kind of request in haproxy
#       # update: use public dns recode to point to private ip instead
#       path = "load-balancing haproxy service tcp443 rule 90"
#       configs = {
#         "ssl"         = "req-ssl-sni"
#         "domain-name" = "consul.vyos.sololab"
#         "set backend" = "vyos_consul"
#       }
#     }
#     l4_backend = {
#       path = "load-balancing haproxy backend vyos_consul"
#       configs = {
#         "mode"                = "tcp"
#         "server vyos port"    = "8501"
#         "server vyos address" = "192.168.255.1"
#       }
#     }
#   }
#   path    = each.value.path
#   configs = each.value.configs
# }
