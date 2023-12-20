# consul
# download consul zip
resource "system_file" "consul_zip" {
  path   = "/home/vyos/consul.zip" # "/usr/bin/consul"
  source = var.consul.bin_file_source
}

# unzip and put it to /usr/bin/
resource "null_resource" "consul_bin" {
  depends_on = [system_file.consul_zip]
  triggers = {
    bin_file_source = var.consul.bin_file_source
    host            = var.vm_conn.host
    port            = var.vm_conn.port
    user            = var.vm_conn.user
    password        = sensitive(var.vm_conn.password)
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
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      "sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/consul"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f /usr/bin/consul",
    ]
  }
}

# prepare consul config dir
resource "system_folder" "consul_config" {
  depends_on = [null_resource.consul_bin]
  path       = "/etc/consul.d/"
}

# persist consul config file in dir
resource "system_file" "consul_config" {
  depends_on = [system_folder.consul_config]
  path       = "/etc/consul.d/consul.hcl"
  content    = templatefile("${var.consul.config_file_source}", merge(var.consul.config_file_vars, var.consul.config_file_vars_others))
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.consul.config_file_vars.data_dir}",
      "sudo chown ${var.consul.systemd_file_vars.user}:${var.consul.systemd_file_vars.group} ${var.consul.config_file_vars.data_dir}",
    ]
  }
}

# low down unprivileged port for consul dns, use setcap instead
# resource "system_file" "sysctl_unprivileged_port" {
#   path    = "/etc/sysctl.d/90-unprivileged_port_start.conf"
#   content = <<-EOT
#     net.ipv4.ip_unprivileged_port_start = 53
#   EOT
#   connection {
#     type     = "ssh"
#     host     = var.vm_conn.host
#     port     = var.vm_conn.port
#     user     = var.vm_conn.user
#     password = var.vm_conn.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo sysctl --system",
#     ]
#   }
# }

# persist consul systemd unit file
# https://developer.hashicorp.com/consul/tutorials/production-deploy/deployment-guide#configure-the-consul-process
resource "system_file" "consul_service" {
  depends_on = [system_file.consul_config]
  path       = "/etc/systemd/system/consul.service"
  content    = templatefile(var.consul.systemd_file_source, var.consul.systemd_file_vars)
}

# sudo systemctl list-unit-files --type=service --state=disabled
# debug service: journalctl -u consul.service
# debug from boot log: journalctl -b
resource "system_service_systemd" "consul" {
  depends_on = [
    system_file.consul_service,
  ]
  name    = "consul"
  status  = "started"
  enabled = "true"
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  # enable consul dns query for anonymous
  # https://github.com/CGamesPlay/infra/blob/dff38bddd883b659d01a11c4b463a201dc4304cb/ansible/templates/consul/initial-setup.sh#L16
  # https://discuss.hashicorp.com/t/consul-service-dns-resolution-not-working/21706
  # https://developer.hashicorp.com/consul/tutorials/security/access-control-setup-production#token-for-dns
  provisioner "remote-exec" {
    inline = [
      "/usr/bin/sleep 5",
      #  [[ ! $(consul acl policy list -http-addr=http://192.168.255.2:8500 -token="e95b599e-166e-7d80-08ad-aee76e7ddf19" -format json | jq '.[] | .Name') =~ "anonymous" ]] && \
      # consul acl policy create -http-addr=http://192.168.255.2:8500 -token="e95b599e-166e-7d80-08ad-aee76e7ddf19" -name anonymous -rules - <<'EOF'
      # node_prefix "" {
      #   policy = "read"
      # }
      # service_prefix "" {
      #   policy = "read"
      # }
      # EOF
      <<-EOT
      if [[ ! $(consul acl policy list -http-addr=http://${var.consul.config_file_vars.client_addr}:8500 -token=${var.consul.config_file_vars.token_init_mgmt} -format json | jq '.[] | .Name') =~ 'anonymous' ]]; then
      consul acl policy create -http-addr=http://${var.consul.config_file_vars.client_addr}:8500 -token=${var.consul.config_file_vars.token_init_mgmt} -name anonymous -rules - <<'EOF'
      node_prefix "" {
        policy = "read"
      }
      service_prefix "" {
        policy = "read"
      }
      EOF
      fi;
      EOT
      ,
      "consul acl token update -http-addr=http://${var.consul.config_file_vars.client_addr}:8500 -token=${var.consul.config_file_vars.token_init_mgmt} -id 00000000-0000-0000-0000-000000000002 -policy-name anonymous -description 'Anonymous Token'",
    ]
  }
}

# enable consul dns query for anonymous
# create consul policy for dns
# https://discuss.hashicorp.com/t/consul-service-dns-resolution-not-working/21706
# https://developer.hashicorp.com/consul/tutorials/security/access-control-setup-production#token-for-dns
# resource "consul_acl_policy" "dns" {
#   depends_on  = [system_service_systemd.consul]
#   name        = "DNS"
#   datacenters = ["dc1"]
#   rules       = <<-EOT
#   node_prefix "" {
#     policy = "read"
#   }
#   service_prefix "" {
#     policy = "read"
#   }
#   EOT
# }

# # assign consul dns policy to anonymous token
# # after apply, debug in remote: dig @127.0.0.1 -p 8600 vyos-lts.node.consul
# resource "consul_acl_token_policy_attachment" "dns" {
#   token_id = "00000000-0000-0000-0000-000000000002"
#   policy   = consul_acl_policy.dns.name
# }
