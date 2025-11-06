resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    uid       = var.owner.uid
    gid       = var.owner.gid
    data_dirs = "/mnt/data/powerdns"
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

module "config_map" {
  source = "../../modules/system-config_files"
  owner  = var.owner
  config = {
    create_dir = true
    dir        = "/mnt/data/etc/powerdns"
    files = [
      {
        basename = "entrypoint.sh"
        content  = <<-EOT
          #!/bin/sh
          if [ ! -f "/var/lib/powerdns/pdns.sqlite3" ]; then
              sqlite3 /var/lib/powerdns/pdns.sqlite3 < /usr/local/share/doc/pdns/schema.sqlite3.sql
          fi

          /usr/local/sbin/pdns_server-startup
        EOT
        mode     = 755
      }
    ]
  }
}

module "vyos_container" {
  depends_on = [
    null_resource.init,
    module.config_map,
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  network = {
    create      = true
    name        = "powerdns"
    cidr_prefix = "172.16.40.0/24"
  }
  workloads = [
    {
      name      = "powerdns"
      image     = "zot.vyos.sololab/powerdns/pdns-auth-50:5.0.0"
      pull_flag = "--tls-verify=false"
      # local_image = ""
      others = {
        "environment TZ value"                = "Asia/Shanghai"
        "environment PDNS_AUTH_API_KEY value" = "powerdns"
        "environment PNDS_DNSUPDATE value"    = "yes"

        "network powerdns address"                                   = "172.16.40.10"
        "sysctl parameter net.ipv4.ip_unprivileged_port_start value" = "53"

        "volume pdns_entrypoint source"      = "/mnt/data/etc/powerdns/entrypoint.sh"
        "volume pdns_entrypoint destination" = "/etc/powerdns/entrypoint.sh"
        "volume pdns_data source"            = "/mnt/data/powerdns"
        "volume pdns_data destination"       = "/var/lib/powerdns"

        "entrypoint" = "/usr/bin/tini -- /etc/powerdns/entrypoint.sh"
      }
    }
  ]
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = {
    l4_frontend = {
      path = "load-balancing haproxy service tcp443 rule 40"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "pdns-auth.vyos.sololab"
        "set backend" = "vyos_pdns_ssl"
      }
    }
    l4_backend = {
      path = "load-balancing haproxy backend vyos_pdns_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "8081"
      }
    }
    l7_frontend = {
      path = "load-balancing haproxy service vyos_pdns_ssl"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "8081"
        "mode"            = "tcp"
        "backend"         = "vyos_pdns"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend = {
      path = "load-balancing haproxy backend vyos_pdns"
      configs = {
        "mode"                = "http"
        "server pdns address" = "172.16.40.10"
        "server pdns port"    = "8081"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}

resource "system_file" "consul_service" {
  for_each = toset([
    "./attachments/powerdns.consul.hcl",
  ])
  path    = "/mnt/data/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
