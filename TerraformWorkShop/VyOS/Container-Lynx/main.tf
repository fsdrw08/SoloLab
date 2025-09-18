resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    data_dirs = "/mnt/data/lynx-postgresql"
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
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -rf ${self.triggers.data_dirs}",
  #   ]
  # }
}

# data "terraform_remote_state" "cert" {
#   backend = "local"
#   config = {
#     path = "../../TLS/RootCA/terraform.tfstate"
#   }
# }

# locals {
#   certs = [
#     for cert in data.terraform_remote_state.cert.outputs.signed_certs : cert
#     if cert.name == "tfbackend-pg"
#   ]
# }

# module "config_map" {
#   source      = "../../modules/system-config_files"
#   prov_system = var.prov_system
#   owner = {
#     uid = 26
#     gid = 26
#   }
#   config = {
#     create_dir = true
#     dir        = "/etc/postgresql"
#     files = [
#       {
#         basename = "ssl.conf"
#         content  = <<-EOT
#           ssl = on
#           ssl_cert_file = '/opt/app-root/src/certs/tls.crt' # server certificate
#           ssl_key_file =  '/opt/app-root/src/certs/tls.key' # server private key
#         EOT
#       }
#     ]
#     secrets = [
#       {
#         sub_dir = "certs"
#         files = [
#           {
#             basename = "tls.crt"
#             content  = local.certs.0["cert_pem_chain"]
#           },
#           {
#             basename = "tls.key"
#             content  = local.certs.0["key_pem"]
#           }
#         ]
#       }
#     ]
#   }
# }

module "vyos_container" {
  depends_on = [
    null_resource.init,
    # module.config_map,
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  network = {
    create      = true
    name        = "lynx"
    cidr_prefix = "172.16.50.0/24"
  }
  workloads = [
    {
      name      = "lynx-postgresql"
      image     = "zot.vyos.sololab/sclorg/postgresql-16-c10s:20250912"
      pull_flag = "--tls-verify=false"
      others = {
        "environment TZ value"                        = "Asia/Shanghai"
        "environment POSTGRESQL_ADMIN_PASSWORD value" = "P@ssw0rd"
        "environment POSTGRESQL_DATABASE value"       = "lynx"
        "environment POSTGRESQL_USER value"           = "lynx"
        "environment POSTGRESQL_PASSWORD value"       = "D1q9f0C2&PEW"

        "network lynx address" = "172.16.50.10"

        # "volume postgresql_conf source"      = "/etc/postgresql/ssl.conf"
        # "volume postgresql_conf destination" = "/opt/app-root/src/postgresql-cfg"
        # "volume postgresql_cert source"      = "/etc/postgresql/certs"
        # "volume postgresql_cert destination" = "/opt/app-root/src/certs"
        "volume postgresql_data source"      = "/mnt/data/lynx-postgresql"
        "volume postgresql_data destination" = "/var/lib/pgsql/data"
      }
    },
    {
      name      = "lynx"
      image     = "zot.vyos.sololab/clivern/lynx:0.12.9"
      pull_flag = "--tls-verify=false"
      others = {
        "command"                           = "sh -c &quot;/app/bin/migrate && /app/bin/server&quot;"
        "environment TZ value"              = "Asia/Shanghai"
        "environment APP_NAME value"        = "Lynx"
        "environment APP_PORT value"        = "4000"
        "environment APP_SECRET value"      = "koPmu7TJCwD8mttV9vgWUeU7iuu/zTPOR3sX4UalM9KkYEVGPfyi0PeTVzu1TT8C"
        "environment APP_HOST value"        = "lynx.vyos.sololab"
        "environment APP_HTTP_SCHEMA value" = "https"
        "environment DB_HOSTNAME value"     = "172.16.50.10"
        "environment DB_DATABASE value"     = "lynx"
        "environment DB_USERNAME value"     = "lynx"
        "environment DB_PASSWORD value"     = "D1q9f0C2&PEW"
        "environment DB_PORT value"         = "5432"

        "network lynx address" = "172.16.50.20"
      }
    },
  ]
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = {
    l4_frontend = {
      path = "load-balancing haproxy service tcp443 rule 50"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "lynx.vyos.sololab"
        "set backend" = "lynx_vyos_ssl"
      }
    }
    l4_backend = {
      path = "load-balancing haproxy backend lynx_vyos_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "4000"
      }
    }
    l7_frontend = {
      path = "load-balancing haproxy service tcp4000"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "4000"
        "mode"            = "tcp"
        "backend"         = "lynx_vyos"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend = {
      path = "load-balancing haproxy backend lynx_vyos"
      configs = {
        "mode"                = "http"
        "server vyos address" = "172.16.50.20"
        "server vyos port"    = "4000"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}

