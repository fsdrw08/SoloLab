resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/consul/"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/consul"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/consul/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

resource "vault_pki_secret_backend_cert" "consul" {
  backend     = "pki/ica1_v1"
  name        = "IntCA1-v1-role"
  common_name = "consul.service.consul"
  alt_names = [
    "consul.infra.sololab",
    "server.dc1.consul"
  ]
}

data "vault_generic_secret" "rootca" {
  path = "pki/root/cert/ca"
}

# output "test" {
#   value = data.vault_pki_secret_backend_issuer.root.certificate
#   # value = keys(jsondecode(data.vault_pki_secret_backend_issuers.root.key_info_json))[0]
# }

# data "terraform_remote_state" "root_ca" {
#   backend = "local"
#   config = {
#     path = "../../TLS/RootCA/terraform.tfstate"
#   }
# }

module "consul" {
  depends_on = [
    null_resource.init,
  ]
  source = "../modules/consul"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    # https://releases.hashicorp.com/consul/
    zip_file_source = "http://sws.infra.sololab:4080/releases/consul%5F1.18.0%5Flinux%5Famd64.zip"
    zip_file_path   = "/home/vyos/consul.zip"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    take_charge = false
    user        = "vyos"
    group       = "users"
  }
  storage = {
    dir_target = "/mnt/data/consul"
    dir_link   = "/opt/consul"
  }
  config = {
    main = {
      basename = "consul.hcl"
      content = templatefile("${path.root}/consul/consul.hcl", {
        bind_addr                          = "{{ GetInterfaceIP `eth2` }}"
        dns_addr                           = "{{ GetInterfaceIP `eth2` }}"
        client_addr                        = "{{ GetInterfaceIP `eth2` }}"
        enable_local_script_checks         = true
        data_dir                           = "/opt/consul"
        encrypt                            = "aPuGh+5UDskRAbkLaXRzFoSOcSM+5vAK+NEYOWHJH7w="
        tls_ca_file                        = "/etc/consul.d/certs/ca.crt"
        tls_cert_file                      = "/etc/consul.d/certs/server.crt"
        tls_key_file                       = "/etc/consul.d/certs/server.key"
        tls_verify_incoming                = false
        tls_verify_outgoing                = true
        tls_irpc_verify_server_hostname    = true
        connect_enabled                    = true
        auto_config_oidc_discovery_url     = "https://vault.infra.sololab:8200/v1/identity/oidc"
        auto_config_oidc_discovery_ca_cert = replace(data.vault_generic_secret.rootca.data.certificate, "\n", "\\n")
        auto_config_bound_issuer           = "https://vault.infra.sololab:8200/v1/identity/oidc"
        auto_config_bound_audiences        = "consul-cluster-dc1"
        auto_config_claim_mappings         = "\"/consul/hostname\" = \"node_name\""
        auto_config_claim_assertions       = "value.node_name == \\\"$${node}\\\"" # "value.node_name == \"$${node}\""
        acl_enabled                        = true
        acl_default_policy                 = "deny"
        acl_enable_token_persistence       = true
        acl_token_init_mgmt                = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
        acl_token_agent                    = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
        acl_token_config_file_svc_reg      = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
      })
    }
    tls = {
      ca_basename = "ca.crt"
      # ca_content    = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      ca_content    = data.vault_generic_secret.rootca.data.certificate
      cert_basename = "server.crt"
      cert_content = join("\n", [
        vault_pki_secret_backend_cert.consul.certificate,
        vault_pki_secret_backend_cert.consul.ca_chain
      ])
      # cert_content = format("%s\n%s", lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "consul", null),
      #   # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      #   data.terraform_remote_state.root_ca.outputs.int_ca_pem
      # )
      key_basename = "server.key"
      key_content  = vault_pki_secret_backend_cert.consul.private_key
      # key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "consul", null)
      # https://developer.hashicorp.com/consul/tutorials/production-deploy/deployment-guide#distribute-the-certificates-to-agents
      sub_dir = "certs"
    }
    dir = "/etc/consul.d"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      templatefile_path = "${path.root}/consul/consul.service"
      templatefile_vars = {
        user  = "vyos"
        group = "users"
      }
      target_path = "/etc/systemd/system/consul.service"
    }
  }
}

resource "system_file" "coredns_snippet" {
  depends_on = [module.consul]
  # https://coredns.io/plugins/auto/#:~:text=is%20the%20second.-,The%20default%20is%3A,example.com,-.
  path = "/etc/coredns/snippets/consul_dns.conf"
  # content = file("${path.root}/sws/sws.conf")
  content = templatefile("${path.root}/consul/consul_dns.conf", {
    FQDN    = "consul.infra.sololab"
    IP      = "192.168.255.2"
    DOMAIN  = "consul"
    FORWARD = ". 192.168.255.2:8600"
  })
}

locals {
  consul_post_process = {
    Config-ConsulDNS = {
      script_path = "./consul/Config-ConsulDNS.sh"
      vars = {
        CONSUL_CACERT   = "/etc/consul.d/certs/ca.crt"
        client_addr     = "consul.infra.sololab:8500"
        token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
      }
    }
    Config-TFToken = {
      script_path = "./consul/Config-TFToken.sh"
      vars = {
        CONSUL_CACERT   = "/etc/consul.d/certs/ca.crt"
        client_addr     = "consul.infra.sololab:8500"
        token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
        secret_id       = "ec15675e-2999-d789-832e-8c4794daa8d7"
      }
    }
  }
}

resource "null_resource" "consul_post_process" {
  depends_on = [
    module.consul,
    system_file.coredns_snippet
  ]
  for_each = local.consul_post_process
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

resource "system_file" "consul_consul" {
  depends_on = [
    module.consul,
  ]
  path    = "/etc/consul.d/consul_consul.hcl"
  content = file("${path.root}/consul/consul_consul.hcl")
  user    = "vyos"
  group   = "users"
}
