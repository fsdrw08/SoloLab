resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    uid       = var.owner.uid
    gid       = var.owner.gid
    data_dirs = "/mnt/data/etc /mnt/data/consul-services /mnt/data/zot /mnt/data/zot-tmp"
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
        sudo chown ${self.triggers.uid}:${self.triggers.gid} ${self.triggers.data_dirs}
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

data "terraform_remote_state" "cert" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

locals {
  certs = [
    for cert in data.terraform_remote_state.cert.outputs.signed_certs : cert
    if cert.name == "root"
  ]
}

module "config_map" {
  source = "../../modules/system-config_files"
  owner  = var.owner
  config = {
    create_dir = true
    dir        = "/etc/cockroach"
    files = [
      {
        basename = "cockroach.yaml"
        content  = file("${path.module}/cockroach.yaml")
      }
    ]
    certs = {
      # https://www.cockroachlabs.com/docs/stable/authentication
      ca_cert_content = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      node_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_node_1", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem
      ])
      node_key_content     = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_node_1", null)
      client_cert_basename = "client.root.crt"
      client_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_client_root", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem
      ])
      client_key_basename = "client.root.key"
      client_key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_client_root", null)
      sub_dir             = "certs"
    }

  }
}

module "vyos_container" {
  depends_on = [module.config_map]
  source     = "../../modules/vyos-container"
  vm_conn    = var.prov_system
  network = {
    name        = "zot"
    cidr_prefix = "172.16.20.0/24"
  }
  workloads = [
    {
      name        = "cockroach"
      image       = "docker.io/cockroachdb/cockroach:latest-v24.2"
      local_image = "/mnt/data/offline/images/docker.io_cockroachdb_cockroach_latest-v24.2.tar"
      pull_flag   = "--tls-verify=false"
      others = {
        "network cockroach address" = "172.16.2.10"
        "memory"                    = "1024"

        "environment TZ value" = "Asia/Shanghai"

        "volume cockroach_cert source"      = "/etc/cockroach/certs"
        "volume cockroach_cert destination" = "/certs"
        "volume cockroach_cert mode"        = "ro"
        "volume cockroach_data source"      = "/mnt/data/cockroach"
        "volume cockroach_data destination" = "/cockroach/cockroach-data"

        "arguments" = "start-single-node --sql-addr=:5432 --http-addr=:5443 --certs-dir=/certs --accept-sql-without-tls"
      }
    }
  ]
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [module.vyos_container]
  for_each = {
    l4_frontend = {
      path = "load-balancing haproxy service tcp443 rule 20"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "cockroach.day0.sololab"
        "set backend" = "vyos_cockroach_ssl"
      }
    }
    l4_frontend2 = {
      path = "load-balancing haproxy service tcp443 rule 21"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "cockroach.day0.sololab"
        "set backend" = "vyos_cockroach_ssl"
      }
    }
    l4_backend = {
      path = "load-balancing haproxy backend vyos_cockroach_ssl"
      configs = {
        "mode"                      = "tcp"
        "server vyos address"       = "172.16.2.10"
        "server vyos port"          = "5443"
        "server vyos send-proxy-v2" = ""
      }
    }
    l7_frontend = {
      path = "load-balancing haproxy service vyos_cockroach_ssl"
      configs = {
        "listen-address 127.0.0.1 accept-proxy" = ""
        "port"                                  = "5000"
        "mode"                                  = "tcp"
        "backend"                               = "vyos_cockroach_ssl"
        "ssl certificate"                       = "vyos"
      }
    }
    l7_backend = {
      path = "load-balancing haproxy backend vyos_cockroach_ssl"
      configs = {
        "mode"                = "http"
        "server vyos address" = "172.16.2.10"
        "server vyos port"    = "5443"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}

locals {
  cockroach_post_process = {
    Set-TerraformBackend = {
      script_path = "${path.root}/Set-TerraformBackend.sh"
      vars = {
        container_name = "cockroach"
        certs_dir      = "/certs/"
        listen_addr    = "127.0.0.1:5432"
      }
    }
  }
}

resource "null_resource" "post_process" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = local.cockroach_post_process
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
}
