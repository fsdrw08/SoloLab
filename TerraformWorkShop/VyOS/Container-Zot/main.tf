resource "null_resource" "init" {
  triggers = {
    host      = var.vm_conn.host
    port      = var.vm_conn.port
    user      = var.vm_conn.user
    password  = var.vm_conn.password
    data_dirs = var.data_dirs
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
        sudo mkdir -p ${var.data_dirs}
        sudo chown ${var.runas.uid}:${var.runas.gid} ${var.data_dirs}
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

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "config_map" {
  source  = "../../System/modules/zot"
  vm_conn = var.vm_conn
  runas   = var.runas
  install = {
    server = null
    client = {
      bin_file_dir = "/usr/bin"
      # https://github.com/project-zot/zot/releases
      bin_file_source = "http://files.mgmt.sololab/bin/zli-linux-amd64"
    }
    oras = {
      # https://github.com/oras-project/oras/releases
      tar_file_source = "http://files.mgmt.sololab/bin/oras_1.2.0_linux_amd64.tar.gz"
      tar_file_path   = "/home/vyos/oras_1.2.0_linux_amd64.tar.gz"
      bin_file_dir    = "/usr/local/bin"
    }
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
              updateInterval = "168h"
              # https://github.com/project-zot/zot/issues/2298#issuecomment-1978312708
              trivy = {
                javadbrepository = "zot.mgmt.sololab/aquasecurity/trivy-java-db" # ghcr.io/aquasecurity/trivy-java-db
                dbrepository     = "zot.mgmt.sololab/aquasecurity/trivy-db"      # ghcr.io/aquasecurity/trivy-db
              }
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
            cert   = "/etc/zot/certs/server.crt"
            key    = "/etc/zot/certs/server.key"
            cacert = "/etc/zot/certs/ca.crt"
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
                # https://github.com/project-zot/zot/blob/main/examples/README.md#identity-based-authorization
                anonymousPolicy = ["read"]
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
          level = "info"
        }
      })
    }
    certs = {
      cacert_basename = "ca.crt"
      cacert_content  = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      cert_basename   = "server.crt"
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
  depends_on = [module.config_map]
  path       = "/etc/zot/config-ldap-credentials.json"
  content = jsonencode({
    bindDN       = "uid=readonly,ou=Services,dc=root,dc=sololab"
    bindPassword = "P@ssw0rd"
  })
  uid = var.runas.uid
  gid = var.runas.gid
}

module "vyos_container" {
  depends_on = [module.config_map]
  source     = "../modules/container"
  vm_conn    = var.vm_conn
  network    = var.container.network
  workload   = var.container.workload
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [module.vyos_container]
  for_each   = var.reverse_proxy
  path       = each.value.path
  configs    = each.value.configs
}

resource "vyos_static_host_mapping" "host_mapping" {
  depends_on = [
    module.vyos_container,
    vyos_config_block_tree.reverse_proxy,
  ]
  host = var.dns_record.host
  ip   = var.dns_record.ip
}
