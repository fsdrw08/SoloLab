resource "null_resource" "load_image" {
  triggers = {
    host               = var.vm_conn.host
    port               = var.vm_conn.port
    user               = var.vm_conn.user
    password           = var.vm_conn.password
    image_name         = "docker.io/lldap/lldap:2024-04-24"
    image_archive_path = "/mnt/data/offline/images/docker.io_lldap_lldap_2024-04-24.tar"
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

module "cockroach_conf" {
  source = "../../System/modules/lldap"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = null
  runas = {
    user        = "vyos"
    group       = "users"
    take_charge = false
  }
  config = {
    certs = {
      # https://www.cockroachlabs.com/docs/stable/authentication
      ca_cert_content = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      node_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_node_1", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem,
        # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      ])
      node_key_content     = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_node_1", null)
      client_cert_basename = "client.root.crt"
      client_cert_content = join("", [
        lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockroach_client_root", null),
        data.terraform_remote_state.root_ca.outputs.int_ca_pem,
        # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      ])
      client_key_basename = "client.root.key"
      client_key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockroach_client_root", null)
      sub_dir             = "certs"
    }
    dir = "/etc/cockroach"
  }
}

resource "vyos_config_block_tree" "container_cockroach_network" {
  path = "container network cockroach"

  configs = {
    "prefix" = "172.16.1.0/24"
  }
}

resource "vyos_config_block_tree" "container_cockroach_workload" {
  depends_on = [
    null_resource.load_image,
    module.cockroach_conf,
    vyos_config_block_tree.container_cockroach_network,
  ]

  path = "container name cockroach"

  configs = {
    "image" = "docker.io/lldap/lldap:2024-04-24"

    "network cockroach address" = "172.16.1.10"
    # "port cockroach_http listen-address" = "192.168.255.1"
    # "port cockroach_http source"         = "5443"
    # "port cockroach_http destination"    = "5443"
    # "port cockroach_db listen-address"   = "192.168.255.1"
    # "port cockroach_db source"           = "5432"
    # "port cockroach_db destination"      = "5432"

    "environment TZ value" = "Asia/Shanghai"

    "volume cockroach_cert source"      = "/etc/cockroach/certs"
    "volume cockroach_cert destination" = "/certs"
    "volume cockroach_cert mode"        = "ro"
    "volume cockroach_data source"      = "/mnt/data/cockroach"
    "volume cockroach_data destination" = "/cockroach/cockroach-data"

    "arguments" = "start-single-node --sql-addr=:5432 --http-addr=:5443 --certs-dir=/certs --accept-sql-without-tls"
  }
}

# resource "vyos_config_block_tree" "nat_cockroach_workload" {
#   depends_on = [
#     vyos_config_block_tree.container_cockroach_workload,
#   ]

#   path = "nat destination rule 20"

#   configs = {
#     "description"            = "cockroachws_forward"
#     "inbound-interface name" = "eth1"
#     "protocol"               = "tcp_udp"
#     "destination port"       = "9090"
#     "source address"         = "192.168.255.0/24"
#     "translation address"    = "172.16.0.10"
#   }
# }

resource "vyos_static_host_mapping" "cockroach" {
  depends_on = [
    null_resource.load_image,
    module.cockroach_conf,
    vyos_config_block_tree.container_cockroach_network,
  ]
  host = "cockroach.mgmt.sololab"
  ip   = "192.168.255.1"
}

# https://serverfault.com/questions/1078467/how-to-force-a-specific-routing-based-on-sni-in-haproxy/1078563#1078563
resource "vyos_config_block_tree" "lb_svc_tcp443_rule_cockroach" {
  depends_on = [
    null_resource.load_image,
    module.cockroach_conf,
    vyos_config_block_tree.container_cockroach_network,
  ]
  path = "load-balancing reverse-proxy service tcp443 rule 20"
  configs = {
    "ssl"         = "req-ssl-sni"
    "domain-name" = "cockroach.mgmt.sololab"
    "set backend" = "cockroach_5443"
  }
}

resource "vyos_config_block_tree" "lb_be_cockroach_5443" {
  depends_on = [
    null_resource.load_image,
    module.cockroach_conf,
    vyos_config_block_tree.container_cockroach_network,
  ]
  path = "load-balancing reverse-proxy backend cockroach_5443"
  configs = {
    "mode"                = "tcp"
    "server vyos address" = "172.16.0.10"
    "server vyos port"    = "5443"
  }
}

# https://serverfault.com/questions/1078467/how-to-force-a-specific-routing-based-on-sni-in-haproxy/1078563#1078563
resource "vyos_config_block_tree" "lb_svc_tcp5432" {
  depends_on = [
    null_resource.load_image,
    module.cockroach_conf,
    vyos_config_block_tree.container_cockroach_network,
  ]
  path = "load-balancing reverse-proxy service tcp5432"
  configs = {
    "listen-address" = "192.168.255.1"
    "port"           = "5432"
    "mode"           = "tcp"
    "backend"        = "cockroach_5432"
  }
}

resource "vyos_config_block_tree" "lb_be_cockroach_5432" {
  depends_on = [
    null_resource.load_image,
    module.cockroach_conf,
    vyos_config_block_tree.container_cockroach_network,
  ]
  path = "load-balancing reverse-proxy backend cockroach_5432"
  configs = {
    "mode"                = "tcp"
    "server vyos address" = "172.16.0.10"
    "server vyos port"    = "5432"
  }
}
