resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    data_dirs = "/mnt/data/postgresql"
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

data "terraform_remote_state" "cert" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

locals {
  certs = [
    for cert in data.terraform_remote_state.cert.outputs.signed_certs : cert
    if cert.name == "tfbackend-pg"
  ]
}

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
    name        = "postgresql"
    cidr_prefix = "172.16.50.0/24"
  }
  workloads = [
    {
      name      = "postgresql"
      image     = "zot.vyos.sololab/sclorg/postgresql-16-c10s:20250912"
      pull_flag = "--tls-verify=false"

      # local_image = "/mnt/data/offline/images/quay.io_fedora_postgresql-16_latest.tar"
      others = {
        "environment TZ value"                        = "Asia/Shanghai"
        "environment POSTGRESQL_ADMIN_PASSWORD value" = "P@ssw0rd"
        "environment POSTGRESQL_DATABASE value"       = "tfstate"
        "environment POSTGRESQL_USER value"           = "terraform"
        "environment POSTGRESQL_PASSWORD value"       = "terraform"

        "network postgresql address" = "172.16.50.10"

        # "volume postgresql_conf source"      = "/etc/postgresql/ssl.conf"
        # "volume postgresql_conf destination" = "/opt/app-root/src/postgresql-cfg"
        # "volume postgresql_cert source"      = "/etc/postgresql/certs"
        # "volume postgresql_cert destination" = "/opt/app-root/src/certs"
        "volume postgresql_data source"      = "/mnt/data/postgresql"
        "volume postgresql_data destination" = "/var/lib/pgsql/data"
      }
    }
  ]
}

# resource "vyos_config_block_tree" "reverse_proxy" {
#   depends_on = [
#     module.vyos_container,
#   ]
#   for_each = {
#     l4_frontend = {
#       path = "load-balancing haproxy service tcp15432"
#       configs = {
#         "mode"                      = "tcp"
#         "port"                      = "15432"
#         "tcp-request inspect-delay" = "5000"
#         "ssl certificate"           = "vyos"
#         "rule 10 ssl"               = "ssl-fc-sni"
#         "rule 10 domain-name"       = "tf-backend-pg.vyos.sololab"
#         "rule 10 set backend"       = "psql_vyos"
#       }
#     }
#     l4_backend = {
#       path = "load-balancing haproxy backend psql_vyos"
#       configs = {
#         "mode"                = "tcp"
#         "server vyos address" = "172.16.50.10"
#         "server vyos port"    = "5432"
#       }
#     }
#   }
#   path    = each.value.path
#   configs = each.value.configs
# }

