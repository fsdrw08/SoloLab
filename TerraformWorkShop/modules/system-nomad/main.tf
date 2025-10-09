# # nomad
# resource "system_group" "group" {
#   count = var.runas.take_charge == true ? 1 : 0
#   name  = var.runas.group
#   gid   = var.runas.gid
# }

# resource "system_user" "user" {
#   count      = var.runas.take_charge == true ? 1 : 0
#   depends_on = [system_group.group]
#   name       = var.runas.user
#   uid        = var.runas.uid
#   gid        = var.runas.gid
# }

# download nomad zip
resource "system_file" "zip" {
  for_each = {
    for install in var.install : install.zip_file_path => install
  }
  source = each.value.zip_file_source
  path   = each.value.zip_file_path
}

# unzip and put it to ${each.value.bin_file_dir}
resource "null_resource" "bin" {
  depends_on = [system_file.zip]
  for_each = {
    for install in var.install : install.zip_file_path => install
  }
  triggers = {
    file_source   = each.value.zip_file_source
    file_dir      = each.value.bin_file_dir
    bin_file_name = each.value.bin_file_name
    host          = var.vm_conn.host
    port          = var.vm_conn.port
    user          = var.vm_conn.user
    password      = sensitive(var.vm_conn.password)
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
      "command -v unzip >/dev/null 2>&1 && unzip ${each.value.zip_file_path} ${each.value.bin_file_name} -d ${each.value.bin_file_dir} -o",
      "command -v bsdtar >/dev/null 2>&1 && bsdtar -x -f ${each.value.zip_file_path} -C ${each.value.bin_file_dir} ${each.value.bin_file_name}",
      "chmod +x ${each.value.bin_file_dir}/${each.value.bin_file_name}",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "rm -f ${self.triggers.file_dir}/${self.triggers.bin_file_name}",
    ]
  }
}
