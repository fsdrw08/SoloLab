data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

data "jks_keystore" "keystore" {
  password = "changeit"

  key_pair {
    alias       = "sololab"
    certificate = lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "opendj", null)
    private_key = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "opendj", null)

    intermediate_certificates = [
      data.terraform_remote_state.root_ca.outputs.int_ca_pem,
    ]
  }
}

resource "local_file" "keystore" {
  content_base64 = data.jks_keystore.keystore.jks_base64
  filename       = "${path.module}/keystore"
  lifecycle {
    ignore_changes = [
      content_base64
    ]
  }
}

resource "null_resource" "init" {
  depends_on = [local_file.keystore]
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
  provisioner "file" {
    source      = local_file.keystore.filename
    destination = "/mnt/data/offline/others/opendj.jks"
  }
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -rf ${self.triggers.data_dirs}",
  #   ]
  # }
}

module "config_map" {
  depends_on = [local_file.keystore]
  source     = "../../System/modules/opendj"
  vm_conn    = var.vm_conn
  runas      = var.runas
  install    = null
  config = {
    properties = {
      basename = "setup.props"
      content = templatefile("${path.module}/opendj/setup.props", {
        # https://github.com/OpenWIS/open-dj-am-install-scripts/blob/4e08bb61782d7d8621e6e88ba65ec4e8d0f2ace9/deploy-scripts/setup_opendj.properties.orig#L5
        hostname                      = "opendj.mgmt.sololab"
        ldapPort                      = 1389
        ldapsPort                     = 1636
        adminConnectorPort            = 4444
        enableStartTLS                = true
        generateSelfSignedCertificate = false
        useJavaKeyStore               = "/etc/opendj/certs/keystore"
        keyStorePassword              = "changeit"
        rootUserDN                    = "cn=Directory Manager"
        rootUserPasswordFile          = "/etc/opendj/.pw"
        backendType                   = "je"
        addBaseEntry                  = true
        baseDN                        = "dc=root,dc=sololab"
      })
    }
    schema = {
      ldif = [
        # https://github.com/OpenIdentityPlatform/OpenDJ/blob/master/src/site/resources/Example.ldif#L51-L66
        {
          basename = "44-domain_base.ldif"
          content = templatefile("${path.module}/opendj/44-domain_base.ldif", {
            baseDN = "dc=root,dc=sololab"
          })
        },
        {
          basename = "45-groups.ldif"
          content = templatefile("${path.module}/opendj/45-groups.ldif", {
            baseDN = "dc=root,dc=sololab"
          })
        },
        {
          basename = "46-people.ldif"
          content = templatefile("${path.module}/opendj/46-people.ldif", {
            baseDN = "dc=root,dc=sololab"
          })
        },
        {
          basename = "47-services.ldif"
          content = templatefile("${path.module}/opendj/47-services.ldif", {
            baseDN = "dc=root,dc=sololab"
          })
        },
      ]
      sub_dir = "schema"
    }
    certs = {
      basename = "keystore"
      source   = "http://files.mgmt.sololab/others/opendj.jks"
      sub_dir  = "certs"
    }
    dir = "/etc/opendj"
  }
  storage = null
}


module "vyos_container" {
  depends_on = [
    null_resource.init,
    module.config_map
  ]
  source   = "../modules/container"
  vm_conn  = var.vm_conn
  network  = var.container.network
  workload = var.container.workload
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

locals {
  post_process = {
    Disable-AnonymousAccess = {
      script_path = "${path.root}/opendj/Disable-AnonymousAccess.sh"
      vars = {
        container_name = "opendj"
        hostname       = "localhost"
        bindDN         = "cn=Directory Manager"
        bindPassword   = "P@ssw0rd"
      }
    }
  }
}

resource "null_resource" "post_process" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = local.post_process
  triggers = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = sensitive(var.vm_conn.password)
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


# add post process to disable anonymous access
# https://backstage.forgerock.com/docs/ds/6.5/reference/index.html#admin-tools-ref
# https://github.com/OpenIdentityPlatform/OpenDJ/wiki/Administration-Privilege-and-Access#example-62-aci-disable-anonymous-access
# /opt/opendj/bin/dsconfig \
#  get-access-control-handler-prop \
#  --port 4444 \
#  --hostname localhost \
#  --bindDN "cn=Directory Manager" \
#  --bindPassword P@ssw0rd \
#  --trustAll \
#  --property global-aci


# /opt/opendj/bin/dsconfig \
#  set-global-configuration-prop \
#  --port 4444 \
#  --hostname localhost \
#  --bindDN "cn=Directory Manager" \
#  --bindPassword P@ssw0rd \
#  --trustAll \
#  --no-prompt \
#  --set reject-unauthenticated-requests:true

# and import ldif
# https://github.com/borcsokj/k8s-sandbox/blob/4863b8f1710b665dc0054e6d4f61907c09b0a5d0/k8s/infra/010-opendj.yaml#L151
