resource "null_resource" "load_image" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    image_name         = "docker.io/library/registry:latest"
    image_archive_path = "/mnt/data/offline/images/docker.io_library_registry_latest.tar"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/Load-ContainerImage.sh", {
        image_name         = self.triggers.image_name
        image_archive_path = self.triggers.image_archive_path
      })
    ]
  }
}

resource "system_folder" "config" {
  path = "/etc/registry"
}

# https://cockpit-project.org/guide/latest/cockpit-tls.8
resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = "/etc/cockpit/ws-certs.d"
}

data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

resource "system_file" "cert" {
  depends_on = [system_folder.certs]
  path       = "/etc/cockpit/ws-certs.d/cockpit.crt"
  content = join("", [
    lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "cockpit", null),
    data.terraform_remote_state.root_ca.outputs.int_ca_pem,
  ])
}

resource "system_file" "key" {
  depends_on = [system_folder.certs]
  path       = "/etc/cockpit/ws-certs.d/cockpit.key"
  content    = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "cockpit", null)
}

resource "vyos_config_block_tree" "container_cockpit_network" {
  path = "container network cockpit"

  configs = {
    "prefix" = "172.16.0.0/24"
  }
}

resource "vyos_config_block_tree" "container_cockpit_workload" {
  depends_on = [
    system_file.cert,
    system_file.key,
    vyos_config_block_tree.container_cockpit_network,
  ]

  path = "container name cockpit"

  configs = {
    "image" = "quay.io/cockpit/ws:latest"

    "network cockpit address"         = "172.16.0.10"
    "port cockpitws_http source"      = "9090"
    "port cockpitws_http destination" = "9090"

    "environment TZ value" = "Asia/Shanghai"

    "volume cockpit_cert source"      = system_folder.certs.path
    "volume cockpit_cert destination" = "/etc/cockpit/ws-certs.d"
  }
}

# resource "vyos_config_block_tree" "nat_cockpit_workload" {
#   depends_on = [
#     vyos_config_block_tree.container_cockpit_workload,
#   ]

#   path = "nat destination rule 20"

#   configs = {
#     "description"            = "cockpitws_forward"
#     "inbound-interface name" = "eth1"
#     "protocol"               = "tcp_udp"
#     "destination port"       = "9090"
#     "source address"         = "192.168.255.0/24"
#     "translation address"    = "172.16.0.10"
#   }
# }

resource "vyos_static_host_mapping" "files" {
  host = "cockpit.mgmt.sololab"
  ip   = "192.168.255.1"
}

# https://serverfault.com/questions/1078467/how-to-force-a-specific-routing-based-on-sni-in-haproxy/1078563#1078563
resource "vyos_config_block_tree" "lb_svc_http_files" {
  path = "load-balancing reverse-proxy service tcp443 rule 30"
  configs = {
    "ssl"         = "req-ssl-sni"
    "domain-name" = "cockpit.mgmt.sololab"
    "set backend" = "cockpit"
  }
}

resource "vyos_config_block_tree" "lb_be_files" {
  path = "load-balancing reverse-proxy backend cockpit"
  configs = {
    "mode"                = "tcp"
    "server vyos address" = "172.16.0.10"
    "server vyos port"    = "9090"
  }
}
