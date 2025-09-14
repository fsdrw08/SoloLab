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

# prepare coredns config dir
resource "system_folder" "config" {
  path = var.config.dir
  uid  = var.runas.uid
  gid  = var.runas.gid
}

resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, basename(var.config.main.basename)])
  content    = var.config.main.content
  uid        = var.runas.uid
  gid        = var.runas.gid
}

resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  count      = var.config.tls == null ? 0 : 1
  path       = join("/", [var.config.dir, var.config.tls.sub_dir])
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "700"
}

resource "system_file" "ca" {
  count = var.config.tls == null ? 0 : var.config.tls.ca_content == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs[0].path, var.config.tls.ca_basename])
  content = var.config.tls.ca_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

resource "system_file" "cert" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs[0].path, var.config.tls.cert_basename])
  content = var.config.tls.cert_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

resource "system_file" "key" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs[0].path, var.config.tls.key_basename])
  content = var.config.tls.key_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

# presist coredns zones config sub dir
# resource "system_folder" "snippets" {
#   depends_on = [system_folder.config]
#   count      = var.config.snippets == null ? 0 : 1
#   path       = join("/", [var.config.dir, var.config.snippets.sub_dir])
#   user       = var.runas.user
#   group      = var.runas.group
#   mode       = "755"
# }
