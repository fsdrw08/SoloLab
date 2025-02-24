# ref: https://www.freedesktop.org/software/systemd/man/latest/systemd.path.html#:~:text=For%20each%20path,(see%20below).
# persist systemd unit files
resource "remote_file" "systemd_unit_files" {
  for_each = {
    for file in var.systemd_unit_files : file.path => file
  }
  path    = each.value.path
  content = each.value.content
}

# # persist systemd service unit file which should trigger by systemd path unit
# resource "remote_file" "systemd_service" {
#   path    = var.systemd_service_unit.path
#   content = var.systemd_service_unit.content
# }

resource "null_resource" "systemd_path_control" {
  depends_on = [
    remote_file.systemd_unit_files,
  ]
  triggers = {
    unit_name = var.systemd_unit_name
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
