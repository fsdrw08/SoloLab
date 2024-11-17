# ref: https://www.freedesktop.org/software/systemd/man/latest/systemd.path.html#:~:text=For%20each%20path,(see%20below).
# persist systemd path unit file
resource "system_file" "systemd_path" {
  path    = var.systemd_path_unit.path
  content = var.systemd_path_unit.content
}

# persist systemd service unit file which should trigger by systemd path unit
resource "system_file" "systemd_service" {
  path    = var.systemd_service_unit.path
  content = var.systemd_service_unit.content
}

resource "system_systemd_unit" "systemd_path" {
  depends_on = [
    system_file.systemd_path,
    system_file.systemd_service
  ]
  type    = "path"
  name    = trimsuffix(system_file.systemd_path.basename, ".path")
  enabled = var.systemd_path_unit.enabled
}

# resource "null_resource" "systemd_path_control" {
#   depends_on = [
#     system_file.systemd_path,
#   ]
#   triggers = {
#     unit_name = system_file.systemd_path.basename
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
