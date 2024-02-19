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

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

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
    zip_file_source = "https://releases.hashicorp.com/consul/1.17.3/consul_1.17.3_linux_amd64.zip"
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
    templatefile_path = "${path.root}/consul/consul.hcl"
    templatefile_vars = {
      bind_addr                  = "{{ GetInterfaceIP `eth2` }}"
      dns_addr                   = "{{ GetInterfaceIP `eth2` }}"
      client_addr                = "{{ GetInterfaceIP `eth2` }}"
      data_dir                   = "/opt/consul"
      encrypt                    = "qDOPBEr+/oUVeOFQOnVypxwDaHzLrD+lvjo5vCEBbZ0="
      tls_ca_file                = "/etc/consul.d/certs/ca.crt"
      tls_cert_file              = "/etc/consul.d/certs/server.crt"
      tls_key_file               = "/etc/consul.d/certs/server.key"
      tls_verify_incoming        = false
      tls_verify_outgoing        = true
      tls_verify_server_hostname = true
      token_init_mgmt            = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
    tls = {
      ca_basename   = "ca.crt"
      ca_content    = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      cert_basename = "server.crt"
      cert_content = format("%s\n%s", lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "consul", null),
        data.terraform_remote_state.root_ca.outputs.root_cert_pem
      )
      key_basename = "server.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "consul", null)
      sub_dir      = "certs"
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

locals {
  consul_post_process = {
    Config-ConsulDNS = {
      script_path = "./consul/Config-ConsulDNS.sh"
      vars = {
        CONSUL_CACERT   = "/etc/consul.d/certs/ca.crt"
        client_addr     = "192.168.255.2:8500"
        token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
      }
    }
    Update-vyOSDNS = {
      script_path = "./consul/Update-vyOSDNS.sh"
      vars = {
        domain = "consul"
        ip     = "192.168.255.2"
      }
    }
  }
}

resource "null_resource" "consul_post_process" {
  depends_on = [module.consul]
  for_each   = local.consul_post_process
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
