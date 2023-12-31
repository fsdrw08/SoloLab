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
      "sudo rm -f ${self.triggers.file_dir}/consul",
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
}

resource "null_resource" "consul_post_process" {
  depends_on = [system_service_systemd.consul]
  for_each   = var.consul_post_process
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
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -f ${self.triggers.file_source}/consul",
  #   ]
  # }
}
