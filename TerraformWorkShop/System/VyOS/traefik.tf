# traefik
# download traefik tar.gz
resource "system_file" "traefik_tar" {
  source = var.traefik.install.tar_file_source
  path   = var.traefik.install.tar_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "traefik_bin" {
  depends_on = [system_file.traefik_tar]
  triggers = {
    file_source = var.traefik.install.tar_file_source
    file_dir    = var.traefik.install.bin_file_dir
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
      # https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-binary-distribution
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --verbose --extract --file=${system_file.traefik_tar.path} --directory=${var.traefik.install.bin_file_dir} --overwrite",
      "sudo chmod 755 ${var.traefik.install.bin_file_dir}/traefik",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/traefik",
    ]
  }
}

# prepare traefik config dir
resource "system_folder" "traefik_config_static" {
  path = var.traefik.config.static.file_path_dir
}

# persist traefik static config file in dir
resource "system_file" "traefik_config_static" {
  depends_on = [system_folder.traefik_config_static]
  path       = format("${var.traefik.config.static.file_path_dir}/%s", basename("${var.traefik.config.static.file_source}"))
  content    = templatefile(var.traefik.config.static.file_source, var.traefik.config.static.vars)
}

# presist traefik dynamic config dir
resource "system_folder" "traefik_config_dynamic" {
  depends_on = [system_folder.traefik_config_static]
  count      = var.traefik.config.dynamic == null ? 0 : 1
  path       = var.traefik.config.dynamic.file_path_dir
}

# persist traefik dynamic config file in dir
resource "system_file" "traefik_config_dynamic" {
  depends_on = [system_folder.traefik_config_dynamic]
  for_each = {
    for content in var.traefik.config.dynamic.file_contents : content.file_source => content
  }
  path = format("${var.traefik.config.dynamic.file_path_dir}/%s", basename("${each.value.file_source}"))
  content = templatefile(
    each.value.file_source,
    each.value.vars
  )
}

# create and link traefik storage dir
resource "system_link" "traefik_data" {
  depends_on = [system_folder.traefik_config_static]
  path       = var.traefik.storage.dir_link
  target     = var.traefik.storage.dir_target
  user       = var.traefik.runas.user
  group      = var.traefik.runas.group
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.traefik.storage.dir_target}",
      "sudo chown ${var.traefik.runas.user}:${var.traefik.runas.group} ${var.traefik.storage.dir_target}",
    ]
  }
}

# persist traefik systemd unit file
resource "system_file" "traefik_service" {
  path = var.traefik.service.traefik.systemd_unit_service.file_path
  content = templatefile(
    var.traefik.service.traefik.systemd_unit_service.file_source,
    var.traefik.service.traefik.systemd_unit_service.vars
  )
}

# debug service: journalctl -u traefik.service
# sudo netstat -apn | grep 80
resource "system_service_systemd" "traefik" {
  depends_on = [
    system_service_systemd.stepca,
    null_resource.traefik_bin,
    system_file.traefik_config_static,
    system_file.traefik_service,
  ]
  name    = trimsuffix(system_file.traefik_service.basename, ".service")
  status  = var.traefik.service.traefik.status
  enabled = var.traefik.service.traefik.enabled
}

# persist traefik restart systemd service unit file
resource "system_file" "traefik_restart_service" {
  path = var.traefik.service.traefik_restart.systemd_unit_service.file_path
  content = templatefile(
    var.traefik.service.traefik_restart.systemd_unit_service.file_source,
    var.traefik.service.traefik_restart.systemd_unit_service.vars
  )
}

# resource "system_service_systemd" "traefik_restart_service" {
#   depends_on = [
#     null_resource.traefik_bin,
#     system_file.traefik_config_static,
#     system_file.traefik_restart_service
#   ]
#   # name = split(".", system_file.traefik_restart_service[each.key].basename)[0]
#   name    = trimsuffix(system_file.traefik_restart_service.basename, ".service")
#   enabled = var.traefik.service.traefik_restart.enabled
# }

# persist traefik restart systemd path unit file
resource "system_file" "traefik_restart_path" {
  path = var.traefik.service.traefik_restart.systemd_unit_path.file_path
  content = templatefile(
    var.traefik.service.traefik_restart.systemd_unit_path.file_source,
    var.traefik.service.traefik_restart.systemd_unit_path.vars
  )
}

resource "null_resource" "traefik_restart_path" {
  depends_on = [
    system_file.traefik_restart_path,
  ]
  triggers = {
    unit_name = system_file.traefik_restart_path.basename
    host      = var.vm_conn.host
    port      = var.vm_conn.port
    user      = var.vm_conn.user
    password  = sensitive(var.vm_conn.password)
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
      "sleep 5",
      "sudo systemctl enable ${self.triggers.unit_name} --now",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl disable ${self.triggers.unit_name} --now",
    ]
  }
}

# https://developer.hashicorp.com/consul/tutorials/get-started-vms/virtual-machine-gs-service-discovery#modify-service-definition-tags
resource "system_file" "traefik_consul" {
  depends_on = [system_service_systemd.traefik]
  path       = "${system_folder.consul_config.path}/traefik.hcl"
  content    = file("./traefik/traefik_consul.hcl")
  user       = "vyos"
  group      = "users"
}

resource "system_file" "consul-ui_consul" {
  depends_on = [system_service_systemd.traefik]
  path       = "${system_folder.consul_config.path}/consul-ui.hcl"
  content    = file("./consul/consul_consul.hcl")
  user       = "vyos"
  group      = "users"
}
