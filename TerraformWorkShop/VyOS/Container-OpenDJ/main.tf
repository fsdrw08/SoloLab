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
    host               = var.vm_conn.host
    port               = var.vm_conn.port
    user               = var.vm_conn.user
    password           = var.vm_conn.password
    image_name         = "docker.io/openidentityplatform/opendj:4.6.2"
    image_archive_path = "/mnt/data/offline/images/docker.io_openidentityplatform_opendj_4.6.2.tar"
    dirs               = "/mnt/data/opendj"
    # https://github.com/OpenIdentityPlatform/OpenDJ/blob/fe3b09f4a34ebc81725fd7263990839afd345752/opendj-packages/opendj-docker/Dockerfile-alpine
    chown_uid = 1001
    chown_gid = 101
    chown_dir = "/mnt/data/opendj"
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
  provisioner "file" {
    source      = local_file.keystore.filename
    destination = "/mnt/data/offline/others/opendj.jks"
  }
  lifecycle {
    prevent_destroy = false
  }
}



module "opendj_conf" {
  depends_on = [local_file.keystore]
  source     = "../../System/modules/opendj"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  runas = {
    user        = 1001
    group       = 101
    uid         = 1001
    gid         = 101
    take_charge = false
  }
  install = null
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

resource "vyos_config_block_tree" "container_network" {
  path = "container network opendj"

  configs = {
    "prefix" = "172.16.2.0/24"
  }
}

# https://hub.docker.com/r/openidentityplatform/opendj
resource "vyos_config_block_tree" "container_workload" {
  depends_on = [
    null_resource.init,
    module.opendj_conf,
    vyos_config_block_tree.container_network,
  ]

  path = "container name opendj"

  configs = {
    "image" = "docker.io/openidentityplatform/opendj:4.6.2"

    "network opendj address" = "172.16.2.10"

    "memory" = "1024"

    "environment TZ value"            = "Asia/Shanghai"
    "environment BASE_DN value"       = "dc=root,dc=sololab"
    "environment ROOT_PASSWORD value" = "P@ssw0rd"
    # pkcs12 doesn't work, use jks instead
    # "environment OPENDJ_SSL_OPTIONS value" = "--usePkcs12keyStore /cert/opendj.pfx --keyStorePassword changeit"
    "environment OPENDJ_SSL_OPTIONS value" = "--useJavaKeystore /opt/opendj/certs/keystore --keyStorePassword changeit"

    "volume opendj_cert source"      = "/etc/opendj/certs"
    "volume opendj_cert destination" = "/opt/opendj/certs"
    "volume opendj_data source"      = "/mnt/data/opendj"
    "volume opendj_data destination" = "/opt/opendj/data"
    # https://github.com/OpenIdentityPlatform/OpenDJ/blob/fe3b09f4a34ebc81725fd7263990839afd345752/opendj-packages/opendj-docker/Dockerfile
    # https://github.com/OpenIdentityPlatform/OpenDJ/blob/master/opendj-packages/opendj-docker/bootstrap/setup.sh#L39-L49
    "volume opendj_schema source"      = "/etc/opendj/schema"
    "volume opendj_schema destination" = "/opt/opendj/bootstrap/schema"
  }
}

locals {
  reverse_proxy = {
    ldap_frontend = {
      path = "load-balancing reverse-proxy service tcp389"
      configs = {
        "listen-address" = "192.168.255.1"
        "port"           = "389"
        "mode"           = "tcp"
        "backend"        = "opendj_ldap"
      }
    }
    ldap_backend = {
      path = "load-balancing reverse-proxy backend opendj_ldap"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.2.10"
        "server vyos port"    = "1389"
      }
    }
    ldaps_frontend = {
      path = "load-balancing reverse-proxy service tcp636"
      configs = {
        "listen-address" = "192.168.255.1"
        "port"           = "636"
        "mode"           = "tcp"
        "backend"        = "opendj_ldaps"
      }
    }
    ldaps_backend = {
      path = "load-balancing reverse-proxy backend opendj_ldaps"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.2.10"
        "server vyos port"    = "1636"
      }
    }
  }
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
    null_resource.init,
    vyos_config_block_tree.reverse_proxy,
  ]
  host = "opendj.mgmt.sololab"
  ip   = "192.168.255.1"
}

resource "null_resource" "post_process" {
  depends_on = [
    vyos_config_block_tree.container_workload,
  ]
  for_each = local.post_process
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
