# consul
# download consul zip
resource "system_file" "consul_zip" {
  source = var.consul.install.zip_file_source
  path   = var.consul.install.zip_file_path # "/usr/bin/consul"
}

# unzip and put it to /usr/bin/
resource "null_resource" "consul_bin" {
  depends_on = [system_file.consul_zip]
  triggers = {
    file_source = var.consul.install.zip_file_source
    file_dir    = var.consul.install.bin_file_dir
    host        = var.vm_conn.host
    port        = var.vm_conn.port
    user        = var.vm_conn.user
    password    = sensitive(var.vm_conn.password)
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
      "sudo unzip ${system_file.consul_zip.path} -d ${var.consul.install.bin_file_dir} -o",
      "sudo chmod 755 ${var.consul.install.bin_file_dir}/consul",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.consul.install.bin_file_dir}/consul"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_source}/consul",
    ]
  }
}

# prepare consul config dir
resource "system_folder" "consul_config" {
  path = var.consul.config.file_path_dir
}

# persist consul config file in dir
resource "system_file" "consul_config" {
  depends_on = [system_folder.consul_config]
  path       = format("${var.consul.config.file_path_dir}/%s", basename("${var.consul.config.file_source}"))
  content    = templatefile(var.consul.config.file_source, var.consul.config.vars)
}

resource "system_link" "consul_data" {
  path   = var.consul.storage.dir_link
  target = var.consul.storage.dir_target
  user   = var.consul.runas.user
  group  = var.consul.runas.group
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.consul.storage.dir_target}",
      "sudo chown ${var.consul.runas.user}:${var.consul.runas.group} ${var.consul.storage.dir_target}",
    ]
  }
}

resource "null_resource" "consul_init" {
  count = var.consul.init_script == null ? 0 : 1
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = templatefile(var.consul.init_script.file_source, var.consul.init_script.vars)
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
  path    = var.consul.service.systemd.file_path
  content = templatefile(var.consul.service.systemd.file_source, var.consul.service.systemd.vars)
}

# sudo systemctl list-unit-files --type=service --state=disabled
# debug service: journalctl -u consul.service
# debug from boot log: journalctl -b
resource "system_service_systemd" "consul" {
  depends_on = [
    null_resource.consul_bin,
    system_file.consul_config,
    system_file.consul_service,
  ]
  name    = trimsuffix(system_file.consul_service.basename, ".service")
  status  = var.consul.service.status
  enabled = var.consul.service.enabled
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
      if [[ ! $(consul acl policy list -http-addr=http://${var.consul.config.vars.client_addr}:8500 -token=${var.consul.config.vars.token_init_mgmt} -format json | jq '.[] | .Name') =~ 'anonymous' ]]; then
      consul acl policy create -http-addr=http://${var.consul.config.vars.client_addr}:8500 -token=${var.consul.config.vars.token_init_mgmt} -name anonymous -rules - <<'EOF'
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
      "consul acl token update -http-addr=http://${var.consul.config.vars.client_addr}:8500 -token=${var.consul.config.vars.token_init_mgmt} -id 00000000-0000-0000-0000-000000000002 -policy-name anonymous -description 'Anonymous Token'",
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
