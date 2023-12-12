# consul
resource "system_file" "consul_zip" {
  path   = "/home/vyos/consul.zip" # "/usr/bin/consul"
  source = "https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip"
}

resource "null_resource" "consul_bin" {
  depends_on = [system_file.consul_zip]
  triggers = {
    consul_version = var.consul_version
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
      "sudo unzip ${system_file.consul_zip.path} -d /usr/bin/ -o",
      "sudo chmod 755 /usr/bin/consul",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f /usr/bin/consul",
    ]
  }
}

resource "system_folder" "consul_config" {
  depends_on = [null_resource.consul_bin]
  path       = "/etc/consul.d/"
}

resource "system_file" "consul_config" {
  depends_on = [system_folder.consul_config]
  path       = "/etc/consul.d/consul.hcl"
  content = templatefile("${path.module}/consul.hcl", {
    data_dir = "/mnt/data/consul",
    dns_addr = "192.168.255.2"
  })
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /mnt/data/consul",
      "sudo chown vyos:users /mnt/data/consul",
    ]
  }
}

resource "system_file" "consul_service" {
  depends_on = [system_file.consul_config]
  path       = "/etc/systemd/system/consul.service"
  content = templatefile("${path.module}/consul.service.tftpl", {
    user  = "vyos",
    group = "users",
  })
}

# resource "vyos_config" "container_Consul_nat" {
#   path = "nat destination rule 20"
#   value = jsonencode({
#     "description"       = "consul forward"
#     "inbound-interface" = "eth1"
#     "protocol"          = "tcp_udp"
#     "source" = {
#       "address" = "192.168.255.0/24"
#     }
#     "translation" = {
#       "address" = "172.16.0.10"
#     }
#   })
# }

# sudo systemctl list-unit-files --type=service --state=disabled
# journalctl -u consul.service
resource "system_service_systemd" "consul" {
  depends_on = [
    system_file.consul_service,
  ]
  name    = "consul"
  status  = "started"
  enabled = "true"
}

# create consul policy for dns
# https://discuss.hashicorp.com/t/consul-service-dns-resolution-not-working/21706
# https://developer.hashicorp.com/consul/tutorials/security/access-control-setup-production#token-for-dns
resource "consul_acl_policy" "dns" {
  depends_on  = [system_service_systemd.consul]
  name        = "DNS"
  datacenters = ["dc1"]
  rules       = <<-EOT
  node_prefix "" {
    policy = "read"
  }
  service_prefix "" {
    policy = "read"
  }
  EOT
}

# assign consul policy to anonymous token
# after apply, debug in remote: dig @127.0.0.1 -p 8600 vyos-lts.node.consul
resource "consul_acl_token_policy_attachment" "dns" {
  token_id = "00000000-0000-0000-0000-000000000002"
  policy   = consul_acl_policy.dns.name
}
