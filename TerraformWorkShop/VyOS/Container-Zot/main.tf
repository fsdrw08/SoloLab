resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    uid       = var.runas.uid
    gid       = var.runas.gid
    data_dirs = "/mnt/data/zot /mnt/data/zot-tmp"
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
    if cert.name == "zot.vyos"
  ]
}

# zot config
module "config_map" {
  source  = "../../modules/system-zot"
  vm_conn = var.prov_system
  runas   = var.runas
  install = []
  config = {
    create_dir = true
    dir        = "/etc/zot"
    # https://zotregistry.dev/v2.1.8/admin-guide/admin-configuration/#configuration-file
    main = {
      basename = "config.json"
      content  = jsonencode(yamldecode(file("${path.module}/attachments/config-htpasswd.yaml")))
    }
    tls = {
      ca_basename   = "ca.crt"
      ca_content    = local.certs.0["ca"]
      cert_basename = "server.crt"
      cert_content  = local.certs.0["cert_pem_chain"]
      key_basename  = "server.key"
      key_content   = local.certs.0["key_pem"]
      sub_dir       = "certs"
    }
  }
}

# for ldap auth
# To allow for separation of configuration and credentials, 
# the credentials for the LDAP server are specified in a separate file, as shown in the following example.
# resource "system_file" "ldap_credential" {
#   depends_on = module.config_map[]
#   path       = "/etc/zot/config-ldap-credentials.json"
#   content = jsonencode({
#     bindDN       = "uid=readonly,ou=Services,dc=root,dc=sololab"
#     bindPassword = "P@ssw0rd"
#   })
#   uid = var.runas.uid
#   gid = var.runas.gid
# }

# for htpasswd auth
resource "system_file" "htpasswd" {
  depends_on = [module.config_map]
  path       = "/etc/zot/htpasswd"
  content    = "admin:$2y$05$S94dvsnxtN2tTONk8eTGEuABGfzDAcXXqkWbIg62mHyOe71PWRRGa"
  uid        = var.runas.uid
  gid        = var.runas.gid
}

module "vyos_container" {
  depends_on = [module.config_map]
  source     = "../../modules/vyos-container"
  vm_conn    = var.prov_system
  network = {
    name        = "zot"
    cidr_prefix = "172.16.20.0/24"
  }
  workload = {
    name        = "zot"
    image       = "quay.io/giantswarm/zot-linux-amd64:v2.1.8"
    local_image = "/mnt/data/offline/images/quay.io_giantswarm_zot-linux-amd64_v2.1.8.tar"
    pull_flag   = "--tls-verify=false"
    others = {
      "uid"                  = var.runas.uid
      "gid"                  = var.runas.gid
      "environment TZ value" = "Asia/Shanghai"
      "network zot address"  = "172.16.20.10"

      "volume zot_config source"      = "/etc/zot"
      "volume zot_config destination" = "/etc/zot"
      "volume zot_config mode"        = "ro"
      "volume zot_data source"        = "/mnt/data/zot"
      "volume zot_data destination"   = "/var/lib/registry"
      "volume zot_tmp source"         = "/mnt/data/zot-tmp"
      "volume zot_tmp destination"    = "/tmp"
    }
  }
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [module.vyos_container]
  for_each = {
    web_frontend = {
      path = "load-balancing haproxy service tcp443 rule 20"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "zot.vyos.sololab.dev"
        "set backend" = "zot_vyos"
      }
    }
    web_frontend2 = {
      path = "load-balancing haproxy service tcp443 rule 21"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "zot.vyos.sololab"
        "set backend" = "zot_vyos"
      }
    }
    web_backend = {
      path = "load-balancing haproxy backend zot_vyos"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.20.10"
        "server vyos port"    = "5000"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}
