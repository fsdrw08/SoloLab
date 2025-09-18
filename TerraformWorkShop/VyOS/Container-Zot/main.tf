resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    uid       = var.owner.uid
    gid       = var.owner.gid
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
    if cert.name == "root"
  ]
}

# zot config
module "config_map" {
  source      = "../../modules/system-config_files"
  prov_system = var.prov_system
  owner       = var.owner
  config = {
    create_dir = true
    dir        = "/etc/zot"
    # https://zotregistry.dev/v2.1.8/admin-guide/admin-configuration/#configuration-file
    files = [
      {
        basename = "config.json"
        content  = jsonencode(yamldecode(file("${path.module}/attachments/config-htpasswd.yaml")))
      },
      # for htpasswd auth
      # https://zotregistry.dev/v2.1.8/articles/authn-authz/#htpasswd
      {
        basename = "htpasswd"
        content  = "admin:$2y$05$S94dvsnxtN2tTONk8eTGEuABGfzDAcXXqkWbIg62mHyOe71PWRRGa"
      },
      # for ldap auth
      # https://zotregistry.dev/v2.1.8/articles/authn-authz/#server-side-authentication
      # {
      #   basename = "config-ldap-credentials.json"
      #   content = jsonencode({
      #     bindDN       = "uid=readonly,ou=Services,dc=root,dc=sololab"
      #     bindPassword = "P@ssw0rd"
      #   })
      # }
    ]
    secrets = [
      {
        sub_dir = "certs"
        files = [
          {
            basename = "ca.crt"
            content  = local.certs.0["ca"]
          },
          # {
          #   basename = "server.crt"
          #   content  = local.certs.0["cert_pem_chain"]
          # },
          # {
          #   basename = "server.key"
          #   content  = local.certs.0["key_pem"]
          # }
        ]
      }
    ]
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
      name  = "zot"
      image = "quay.io/giantswarm/zot-linux-amd64:v2.1.8"
      # image       = "192.168.255.10:5000/giantswarm/zot:v2.1.8"
      local_image = "/mnt/data/offline/images/quay.io_giantswarm_zot-linux-amd64_v2.1.8.tar"
      pull_flag   = "--tls-verify=false"
      others = {
        "uid"                  = var.owner.uid
        "gid"                  = var.owner.gid
        "environment TZ value" = "Asia/Shanghai"
        # https://github.com/project-zot/zot/issues/2298#issuecomment-1978312708
        "environment SSL_CERT_DIR value" = "/etc/zot/certs"
        "network zot address"            = "172.16.20.10"

        "volume zot_config source"      = "/etc/zot"
        "volume zot_config destination" = "/etc/zot"
        "volume zot_config mode"        = "ro"
        "volume zot_data source"        = "/mnt/data/zot"
        "volume zot_data destination"   = "/var/lib/registry"
        "volume zot_tmp source"         = "/mnt/data/zot-tmp"
        "volume zot_tmp destination"    = "/tmp"
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
        "domain-name" = "zot.vyos.sololab.dev"
        "set backend" = "zot_vyos_ssl"
      }
    }
    l4_frontend2 = {
      path = "load-balancing haproxy service tcp443 rule 21"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "zot.vyos.sololab"
        "set backend" = "zot_vyos_ssl"
      }
    }
    l4_backend = {
      path = "load-balancing haproxy backend zot_vyos_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "5000"
      }
    }
    l7_frontend = {
      path = "load-balancing haproxy service tcp5000"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "5000"
        "mode"            = "tcp"
        "backend"         = "zot_vyos"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend = {
      path = "load-balancing haproxy backend zot_vyos"
      configs = {
        "mode"                = "http"
        "server vyos address" = "172.16.20.10"
        "server vyos port"    = "5000"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}
