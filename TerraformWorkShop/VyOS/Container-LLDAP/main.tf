resource "null_resource" "load_image" {
  triggers = {
    host               = var.vm_conn.host
    port               = var.vm_conn.port
    user               = var.vm_conn.user
    password           = var.vm_conn.password
    image_name         = "docker.io/lldap/lldap:2024-04-24-debian-rootless"
    image_archive_path = "/mnt/data/offline/images/docker.io_lldap_lldap_2024-04-24-debian-rootless.tar"
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
      templatefile("${path.root}/Load-ContainerImage.sh", {
        image_name         = self.triggers.image_name
        image_archive_path = self.triggers.image_archive_path
      })
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo podman image rm ${self.triggers.image_name}"
    ]
  }
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

module "lldap_conf" {
  source = "../../System/modules/lldap"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  runas = {
    user        = "vyos"
    group       = "users"
    take_charge = false
  }
  install = null
  config = {
    main = {
      basename = "lldap_config.toml"
      content = templatefile("${path.root}/lldap/lldap_config.toml", {
        # ldap_host       = "192.168.255.1"
        # http_host       = "192.168.255.1"
        # ldap_port       = "389"
        # http_port       = "17170"
        # http_url        = "https://lldap.infra.sololab"
        jwt_secret      = "REPLACE_WITH_RANDOM"
        ldap_base_dn    = "dc=root,dc=sololab"
        ldap_user_dn    = "admin"
        ldap_user_pass  = "P@ssw0rd"
        database_url    = "sqlite:///data/db/users.db?mode=rwc"
        key_file        = "/data/db/private_key"
        ldaps_enabled   = "false"
        ldaps_port      = "6360"
        ldaps_cert_file = "/data/config/certs/server.crt"
        ldaps_key_file  = "/data/config/certs/server.key"
      })
    }
    certs = {
      cert_basename = "server.crt"
      cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "lldap", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem,
        # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      ])
      key_basename = "server.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "lldap", null)
      sub_dir      = "certs"
    }
    dir = "/etc/lldap"
  }
  storage = null
}

resource "vyos_config_block_tree" "container_network" {
  path = "container network lldap"

  configs = {
    "prefix" = "172.16.1.0/24"
  }
}

resource "vyos_config_block_tree" "container_workload" {
  depends_on = [
    null_resource.load_image,
    module.lldap_conf,
    vyos_config_block_tree.container_network,
  ]

  path = "container name lldap"

  configs = {
    "image" = "docker.io/lldap/lldap:2024-04-24-debian-rootless"

    "network lldap address" = "172.16.1.10"
    # "port lldap_http listen-address" = "192.168.255.1"
    # "port lldap_http source"         = "17170"
    # "port lldap_http destination"    = "17170"
    # "port lldap_ldap listen-address" = "192.168.255.1"
    # "port lldap_ldap source"         = "389"
    # "port lldap_ldap destination"    = "389"

    "uid" = "0"
    "gid" = "0"

    "environment TZ value"              = "Asia/Shanghai"
    "environment LLDAP_HTTP_PORT value" = "17170"
    "environment LLDAP_HTTP_URL value"  = "https://lldap.day0.sololab"
    "environment LLDAP_LDAP_PORT value" = "3890"

    "volume lldap_config source"      = "/etc/lldap"
    "volume lldap_config destination" = "/data/config"
    "volume lldap_data source"        = "/mnt/data/lldap"
    "volume lldap_data destination"   = "/data/db"

    "entrypoint" = "/app/lldap"
    "command"    = "run --config-file /data/config/lldap_config.toml"
  }
}

resource "system_file" "nginx_config" {
  path = "/etc/nginx/conf.d/lldap.conf"
  content = templatefile("${path.module}/lldap/lldap_nginx.conf", {
    listen              = "127.0.0.1:17170 ssl"
    server_name         = "lldap.day0.sololab"
    ssl_certificate     = "/etc/lldap/certs/server.crt"
    ssl_certificate_key = "/etc/lldap/certs/server.key"
    proxy_pass          = "http://172.16.1.10:17170/"
  })
  user  = "vyos"
  group = "users"
  mode  = "644"
}

locals {
  reverse_proxy = {
    web_frontend = {
      path = "load-balancing reverse-proxy service tcp443 rule 30"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "lldap.day0.sololab"
        "set backend" = "lldap_web"
      }
    }
    web_backend = {
      path = "load-balancing reverse-proxy backend lldap_web"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "17170"
      }
    }
    ldap_frontend = {
      path = "load-balancing reverse-proxy service tcp389"
      configs = {
        "listen-address" = "192.168.255.1"
        "port"           = "389"
        "mode"           = "tcp"
        "backend"        = "lldap_ldap"
      }
    }
    ldap_backend = {
      path = "load-balancing reverse-proxy backend lldap_ldap"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.1.10"
        "server vyos port"    = "3890"
      }
    }
    ldaps_frontend = {
      path = "load-balancing reverse-proxy service tcp636"
      configs = {
        "listen-address" = "192.168.255.1"
        "port"           = "636"
        "mode"           = "tcp"
        "backend"        = "lldap_ldaps"
      }
    }
    ldaps_backend = {
      path = "load-balancing reverse-proxy backend lldap_ldaps"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.1.10"
        "server vyos port"    = "6360"
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
    module.lldap_conf,
    vyos_config_block_tree.reverse_proxy,
  ]
  host = "lldap.day0.sololab"
  ip   = "192.168.255.1"
}
