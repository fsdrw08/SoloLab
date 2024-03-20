# sws
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

# download sws tar.gz
resource "system_file" "tar" {
  source = var.install.tar_file_source
  path   = var.install.tar_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "bin" {
  depends_on = [system_file.tar]
  triggers = {
    file_source          = var.install.tar_file_source
    file_dir             = var.install.bin_file_dir
    strip_components_bin = 1
    host                 = var.vm_conn.host
    port                 = var.vm_conn.port
    user                 = var.vm_conn.user
    password             = sensitive(var.vm_conn.password)
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
      # https://doc.sws.io/sws/getting-started/install-sws/#use-the-binary-distribution
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --extract --file=${system_file.tar.path} --directory=${var.install.bin_file_dir} --strip-components=${self.triggers.strip_components_bin} --verbose --overwrite ${var.install.tar_file_bin_path}",
      "sudo chmod 755 ${var.install.bin_file_dir}/static-web-server",
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
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "755"
}

# persist sws config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, basename(var.config.main.basename)])
  content    = var.config.main.content
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

# presist sws cert dir
resource "system_folder" "cert" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.tls.sub_dir])
  user       = var.runas.user
  group      = var.runas.group
  mode       = "700"
}

resource "system_file" "cert" {
  count = var.config.tls.cert_basename == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.cert
  ]
  path    = join("/", [var.config.dir, var.config.tls.sub_dir, var.config.tls.cert_basename])
  content = var.config.tls.cert_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "key" {
  count = var.config.tls.key_basename == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.cert
  ]
  path    = join("/", [var.config.dir, var.config.tls.sub_dir, var.config.tls.key_basename])
  content = var.config.tls.key_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

# persist sws systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# debug service: journalctl -u sws.service
# sudo netstat -apn | grep 80
resource "system_service_systemd" "service" {
  depends_on = [
    null_resource.bin,
    system_file.config,
    system_file.service,
  ]
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
