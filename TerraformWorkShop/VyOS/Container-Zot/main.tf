resource "null_resource" "load_image" {
  triggers = {
    host               = var.vm_conn.host
    port               = var.vm_conn.port
    user               = var.vm_conn.user
    password           = var.vm_conn.password
    image_name         = "ghcr.io/project-zot/zot-linux-amd64:v2.0.4"
    image_archive_path = "/mnt/data/offline/images/ghcr.io_project-zot_zot-linux-amd64_v2.0.4.tar"
    dirs               = "/mnt/data/zot"
    # https://github.com/OpenIdentityPlatform/OpenDJ/blob/fe3b09f4a34ebc81725fd7263990839afd345752/opendj-packages/opendj-docker/Dockerfile-alpine
    chown_uid = 1002
    chown_gid = 100
    chown_dir = "/mnt/data/zot"
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
      templatefile("${path.root}/init.sh", {
        image_name         = self.triggers.image_name
        image_archive_path = self.triggers.image_archive_path
        dirs               = self.triggers.dirs
        chown_uid          = self.triggers.chown_uid
        chown_gid          = self.triggers.chown_gid
        chown_dir          = self.triggers.chown_dir
      })
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo podman image rm ${self.triggers.image_name}",
      "sudo rm -rf ${self.triggers.dirs}",
    ]
  }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "zot_conf" {
  source = "../../System/modules/zot"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  runas = {
    user        = 1002
    group       = 100
    uid         = 1002
    gid         = 100
    take_charge = false
  }
  install = {
    server = null
    client = null
  }
  config = {
    main = {
      # https://zotregistry.dev/v2.0.4/admin-guide/admin-configuration/#configuration-file
      basename = "config.json"
      content = jsonencode({
        extensions = {
          # https://zotregistry.dev/v2.0.4/admin-guide/admin-configuration/#enhanced-searching-and-querying-images
          search = {
            enable = true
            cve = {
              updateInterval = "2h"
            }
          }
          # Mgmt is enabled when the Search extension is enabled
          mgmt = {
            enable = true
          }
          ui = {
            enable = true
          }
          scrub = {
            enable   = true
            interval = "24h"
          }
        }
        http = {
          address = "0.0.0.0"
          port    = "5000"
          realm   = "zot"
          tls = {
            cert = "/etc/zot/certs/server.crt"
            key  = "/etc/zot/certs/server.key"
          }
          auth = {
            # https://zotregistry.dev/v2.0.4/articles/authn-authz/#ldap
            # https://github.com/project-zot/zot/blob/be5ad667974b43905a118a40435f7117c0dde511/examples/config-ldap.json#L17
            ldap = {
              credentialsFile    = "/etc/zot/config-ldap-credentials.json"
              address            = "opendj.mgmt.sololab"
              port               = 636
              startTLS           = true
              baseDN             = "ou=People,dc=root,dc=sololab"
              userAttribute      = "uid"
              userGroupAttribute = "isMemberOf"
              skipVerify         = true
              subtreeSearch      = true
            },
            failDelay = 5
          }
          # https://zotregistry.dev/v2.0.4/articles/authn-authz/#example-access-control-configuration
          accessControl = {
            repositories = {
              "**" = {
                policies = [
                  {
                    groups  = ["cn=App-Zot-CU,ou=Groups,dc=root,dc=sololab"]
                    actions = ["read", "update"]
                  }
                ]
                defaultPolicy = ["read"]
              }
            }
            adminPolicy = {
              groups  = ["cn=App-Zot-Admin,ou=Groups,dc=root,dc=sololab"]
              actions = ["read", "create", "update", "delete"]
            }
          }
        }
        # https://zotregistry.dev/v2.0.4/articles/storage/#configuring-zot-storage
        storage = {
          rootDirectory = "/var/lib/registry"
          # https://zotregistry.dev/v2.0.4/articles/storage/#commit
          # make data to be written to disk immediately
          commit = true
          # https://zotregistry.dev/v2.0.4/articles/storage/#garbage-collection
          # Garbage collection (gc) is enabled by default to reclaim this space
          gc = true
        }
        log = {
          level = "debug"
        }
      })
    }
    certs = {
      cert_basename = "server.crt"
      cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "zot", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem
      ])
      key_basename = "server.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "zot", null)
      sub_dir      = "certs"
    }
    dir = "/etc/zot"
  }
}

resource "system_file" "ldap_credential" {
  depends_on = [module.zot_conf]
  path       = "/etc/zot/config-ldap-credentials.json"
  content = jsonencode({
    bindDN       = "uid=readonly,ou=Services,dc=root,dc=sololab"
    bindPassword = "P@ssw0rd"
  })
  uid = 1002
  gid = 100
}

resource "vyos_config_block_tree" "container_network" {
  path = "container network zot"

  configs = {
    "prefix" = "172.16.3.0/24"
  }
}

resource "vyos_config_block_tree" "container_workload" {
  depends_on = [
    null_resource.load_image,
    module.zot_conf,
    vyos_config_block_tree.container_network,
  ]

  path = "container name zot"

  configs = {
    "image" = "ghcr.io/project-zot/zot-linux-amd64:v2.0.4"

    "network zot address" = "172.16.3.10"

    "uid" = "1002"
    "gid" = "100"

    "environment TZ value" = "Asia/Shanghai"

    "volume zot_config source"      = "/etc/zot"
    "volume zot_config destination" = "/etc/zot"
    "volume zot_config mode"        = "ro"
    "volume zot_data source"        = "/mnt/data/zot"
    "volume zot_data destination"   = "/var/lib/registry"
  }
}

locals {
  reverse_proxy = {
    web_frontend = {
      path = "load-balancing reverse-proxy service tcp443 rule 30"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "zot.mgmt.sololab"
        "set backend" = "zot_web"
      }
    }
    web_backend = {
      path = "load-balancing reverse-proxy backend zot_web"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.3.10"
        "server vyos port"    = "5000"
      }
    }
  }
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    vyos_config_block_tree.container_workload
  ]
  for_each = local.reverse_proxy
  path     = each.value.path
  configs  = each.value.configs
}

resource "vyos_static_host_mapping" "host_mapping" {
  depends_on = [
    null_resource.load_image,
    vyos_config_block_tree.reverse_proxy,
  ]
  host = "zot.mgmt.sololab"
  ip   = "192.168.255.1"
}
