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
  source = var.install.tar_file_source
  path   = var.install.tar_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "bin" {
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
      "sudo tar --verbose --extract --file=${system_file.tar.path} --directory=${var.install.bin_file_dir} --overwrite coredns",
      "sudo chmod 755 ${var.install.bin_file_dir}/coredns",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl daemon-reload",
      "sudo rm -f ${self.triggers.file_dir}/coredns",
    ]
  }
}

# prepare coredns config dir
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "755"
}

# persist coredns corefile config file in dir
resource "system_file" "corefile" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, "Corefile"])
  content    = var.config.corefile.content
  user       = var.runas.user
  group      = var.runas.group
  mode       = "755"
}

# presist coredns zones config sub dir
resource "system_folder" "snippets" {
  depends_on = [system_folder.config]
  count      = var.config.snippets == null ? 0 : 1
  path       = join("/", [var.config.dir, var.config.snippets.sub_dir])
  user       = var.runas.user
  group      = var.runas.group
  mode       = "755"
}

# persist coredns zones config file in dir
# resource "system_file" "zones" {
#   depends_on = [system_folder.zones]
#   for_each = {
#     for file in var.config.zones.files : file.basename => file
#   }
#   path    = join("/", [var.config.dir, var.config.zones.sub_dir, each.value.basename])
#   content = each.value.content
#   user    = var.runas.user
#   group   = var.runas.group
#   mode    = "755"
# }

# persist coredns systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# debug service: journalctl -u coredns.service
# sudo netstat -apn | grep 80
resource "system_service_systemd" "service" {
  depends_on = [
    null_resource.bin,
    system_file.corefile,
    system_file.service,
  ]
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
