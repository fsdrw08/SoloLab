resource "system_file" "sws_tar" {
  source = var.sws.install.tar_file_source
  path   = var.sws.install.tar_file_path # "/usr/local/bin/"
}

# extra and put it to /usr/bin/
resource "null_resource" "sws_bin" {
  depends_on = [system_file.sws_tar]
  triggers = {
    file_source      = var.sws.install.tar_file_source
    file_dir         = var.sws.install.bin_file_dir
    strip_components = index(split("/", var.sws.install.tar_file_bin_path), "static-web-server")
    host             = var.vm_conn.host
    port             = var.vm_conn.port
    user             = var.vm_conn.user
    password         = sensitive(var.vm_conn.password)
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
      "sudo tar --extract --file=${system_file.sws_tar.path} --directory=${var.sws.install.bin_file_dir} --strip-components=1 --verbose --overwrite ${var.sws.install.tar_file_bin_path}",
      "sudo chmod 755 ${var.sws.install.bin_file_dir}/static-web-server",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.sws.install.bin_file_dir}/sws"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/static-web-server",
    ]
  }
}

# prepare sws config dir
resource "system_folder" "sws_config" {
  path = var.sws.config.file_path_dir
}

# persist sws config file
resource "system_file" "sws_config" {
  path    = format("${var.sws.config.file_path_dir}/%s", basename("${var.sws.config.file_source}"))
  content = templatefile(var.sws.config.file_source, var.sws.config.vars)
}

resource "null_resource" "sws_data" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.sws.storage.dir_target}",
      "sudo chown ${var.sws.runas.user}:${var.sws.runas.group} ${var.sws.storage.dir_target}",
    ]
  }
}

resource "system_file" "sws_service" {
  depends_on = [null_resource.sws_bin]
  path       = var.sws.service.sws.systemd_unit_service.file_path
  content = templatefile(
    var.sws.service.sws.systemd_unit_service.file_source,
    var.sws.service.sws.systemd_unit_service.vars
  )
}

resource "system_file" "sws_socket" {
  depends_on = [null_resource.sws_bin]
  path       = var.sws.service.sws.systemd_unit_socket.file_path
  content = templatefile(
    var.sws.service.sws.systemd_unit_socket.file_source,
    var.sws.service.sws.systemd_unit_socket.vars
  )
}

resource "null_resource" "sws_socket" {
  depends_on = [
    system_file.sws_service,
    system_file.sws_socket,
  ]
  triggers = {
    unit_name = system_file.sws_socket.basename
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

resource "system_service_systemd" "sws" {
  depends_on = [
    null_resource.sws_bin,
    system_file.sws_config,
    system_file.sws_service,
  ]
  name    = trimsuffix(system_file.sws_service.basename, ".service")
  status  = var.sws.service.sws.status
  enabled = var.sws.service.sws.enabled
}

# resource "system_file" "sws_restart_service" {
#   path = var.sws.service.sws_restart.systemd_unit_service.file_path
#   content = templatefile(
#     var.sws.service.sws_restart.systemd_unit_service.file_source,
#     var.sws.service.sws_restart.systemd_unit_service.vars
#   )
# }

# resource "system_file" "sws_restart_path" {
#   path = var.sws.service.sws_restart.systemd_unit_path.file_path
#   content = templatefile(
#     var.sws.service.sws_restart.systemd_unit_path.file_source,
#     var.sws.service.sws_restart.systemd_unit_path.vars
#   )
# }

# resource "null_resource" "sws_restart_path" {
#   depends_on = [
#     system_file.sws_restart_path,
#   ]
#   triggers = {
#     unit_name = system_file.sws_restart_path.basename
#     host      = var.vm_conn.host
#     port      = var.vm_conn.port
#     user      = var.vm_conn.user
#     password  = sensitive(var.vm_conn.password)
#   }
#   connection {
#     type     = "ssh"
#     host     = self.triggers.host
#     port     = self.triggers.port
#     user     = self.triggers.user
#     password = self.triggers.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sleep 5",
#       "sudo systemctl enable ${self.triggers.unit_name} --now",
#     ]
#   }
#   provisioner "remote-exec" {
#     when = destroy
#     inline = [
#       "sudo systemctl disable ${self.triggers.unit_name} --now",
#     ]
#   }
# }

resource "system_file" "sws_consul" {
  depends_on = [null_resource.sws_socket]
  path       = "${system_folder.consul_config.path}/sws.hcl"
  content    = file("./sws/sws_consul.hcl")
  user       = "vyos"
  group      = "users"
}
