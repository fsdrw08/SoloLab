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
      name      = "postgrest"
      image     = "zot.vyos.sololab/postgrest/postgrest:v13.0.7"
      pull_flag = "--tls-verify=false"

      # local_image = "/mnt/data/offline/images/quay.io_fedora_postgresql-16_latest.tar"
      others = {
        "environment TZ value"           = "Asia/Shanghai"
        "environment PGRST_DB_URI value" = "postgres://terraform:terraform@postgresql/tfstate"
        # https://postgrest.org/en/stable/references/configuration.html#openapi-server-proxy-uri
        "environment PGRST_DB_SCHEMAS value"               = "public"
        "environment PGRST_DB_ANON_ROLE value"             = "terraform"
        "environment PGRST_OPENAPI_SERVER_PROXY_URI value" = "http://172.16.50.20:3000"
        "environment PGRST_OPENAPI_MODE value"             = "ignore-privileges"

        "network postgresql address" = "172.16.50.20"

      }
    },
    {
      name      = "swagger"
      image     = "zot.vyos.sololab/swaggerapi/swagger-ui:v5.29.0"
      pull_flag = "--tls-verify=false"

      # local_image = "/mnt/data/offline/images/quay.io_fedora_postgresql-16_latest.tar"
      others = {
        "environment TZ value" = "Asia/Shanghai"

        "environment API_URL value" = "https://postgrest.vyos.sololab/"

        "network postgresql address" = "172.16.50.30"
      }
    },
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

        "port pgsql source"      = "5432"
        "port pgsql destination" = "5432"
        "port pgsql protocol"    = "tcp"

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

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = {
    l4_frontend_postgrest = {
      path = "load-balancing haproxy service tcp443 rule 50"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "postgrest.vyos.sololab"
        "set backend" = "vyos_postgrest_ssl"
      }
    }
    l4_backend_postgrest = {
      path = "load-balancing haproxy backend vyos_postgrest_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "3000"
      }
    }
    l7_frontend_postgrest = {
      path = "load-balancing haproxy service vyos_postgrest_ssl"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "3000"
        "mode"            = "tcp"
        "backend"         = "vyos_postgrest"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend_postgrest = {
      path = "load-balancing haproxy backend vyos_postgrest"
      configs = {
        "mode"                = "http"
        "server vyos address" = "172.16.50.20"
        "server vyos port"    = "3000"
      }
    }
    l4_frontend_swagger = {
      path = "load-balancing haproxy service tcp443 rule 55"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "swagger.vyos.sololab"
        "set backend" = "vyos_swagger_ssl"
      }
    }
    l4_backend_swagger = {
      path = "load-balancing haproxy backend vyos_swagger_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "8080"
      }
    }
    l7_frontend_swagger = {
      path = "load-balancing haproxy service vyos_swagger_ssl"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "8080"
        "mode"            = "tcp"
        "backend"         = "vyos_swagger"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend_swagger = {
      path = "load-balancing haproxy backend vyos_swagger"
      configs = {
        "mode"                = "http"
        "server vyos address" = "172.16.50.30"
        "server vyos port"    = "8080"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}
