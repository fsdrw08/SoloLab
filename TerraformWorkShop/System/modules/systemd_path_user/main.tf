# ref: https://www.freedesktop.org/software/systemd/man/latest/systemd.path.html#:~:text=For%20each%20path,(see%20below).
# persist systemd path unit file
resource "remote_file" "systemd_path" {
  path    = var.systemd_path_unit.path
  content = var.systemd_path_unit.content
}

# persist systemd service unit file which should trigger by systemd path unit
resource "remote_file" "systemd_service" {
  path    = var.systemd_service_unit.path
  content = var.systemd_service_unit.content
}

# resource "system_service_systemd" "traefik_restart_service" {
#   depends_on = [
#     null_resource.traefik_bin,
#     remote_file.traefik_config_static,
#     remote_file.traefik_restart_service
#   ]
#   # name = split(".", remote_file.traefik_restart_service[each.key].basename)[0]
#   name    = trimsuffix(remote_file.traefik_restart_service.basename, ".service")
#   enabled = var.enabled
# }

resource "null_resource" "systemd_path_control" {
  depends_on = [
    remote_file.systemd_path,
  ]
  triggers = {
    unit_name = basename(remote_file.systemd_path.path)
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
      "systemctl --user enable ${self.triggers.unit_name} --now",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user disable ${self.triggers.unit_name} --now",
    ]
  }
}
