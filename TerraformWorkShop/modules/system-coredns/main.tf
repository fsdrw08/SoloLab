# coredns
resource "system_group" "group" {
  count = var.runas.take_charge == true ? 1 : 0
  name  = var.runas.group
}

resource "system_user" "user" {
  count      = var.runas.take_charge == true ? 1 : 0
  depends_on = [system_group.group]
  name       = var.runas.user
  group      = var.runas.group
}

# download coredns tgz (tar.gz)
resource "system_file" "tar" {
  count  = var.install == null ? 0 : 1
  source = var.install.tar_file_source
  path   = var.install.tar_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "bin" {
  count      = var.install == null ? 0 : 1
  depends_on = [system_file.tar]
  triggers = {
    file_source = var.install.tar_file_source
    file_dir    = var.install.bin_file_dir
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
      # https://github.com/coredns/coredns/releases
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --verbose --extract --file=${system_file.tar.0.path} --directory=${var.install.bin_file_dir} --overwrite coredns",
      "sudo chmod 755 ${var.install.bin_file_dir}/coredns",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/coredns",
    ]
  }
}
