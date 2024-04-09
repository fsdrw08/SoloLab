# registry
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

# download registry tar.gz
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
      # https://unix.stackexchange.com/questions/61461/how-to-extract-specific-files-from-tar-gz/61464#61464
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --verbose --extract --file=${system_file.tar.path} --directory=${var.install.bin_file_dir} --overwrite registry",
      "sudo chmod 755 ${var.install.bin_file_dir}/registry",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl daemon-reload",
      "sudo rm -f ${self.triggers.file_dir}/registry",
    ]
  }
}

# prepare registry config dir
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "755"
}

# persist registry main config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.main.basename])
  content    = var.config.main.content
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

resource "system_file" "htpasswd" {
  count      = var.config.htpasswd == null ? 0 : 1
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.htpasswd.basename])
  content    = var.config.htpasswd.content
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

# presist registry cert dir
resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.certs.sub_dir])
  user       = var.runas.user
  group      = var.runas.group
  mode       = "700"
}

resource "system_file" "ca" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [var.config.dir, var.config.certs.sub_dir, var.config.certs.ca_basename])
  content = var.config.certs.ca_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "cert" {
  count = var.config.certs.cert_basename == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [var.config.dir, var.config.certs.sub_dir, var.config.certs.cert_basename])
  content = var.config.certs.cert_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "key" {
  count = var.config.certs.key_basename == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [var.config.dir, var.config.certs.sub_dir, var.config.certs.key_basename])
  content = var.config.certs.key_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

# create and link registry storage dir
resource "system_link" "data" {
  path   = var.storage.dir_link
  target = var.storage.dir_target
  user   = var.runas.user
  group  = var.runas.group
}

# persist registry systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# debug service: journalctl -u registry.service
# sudo netstat -apn | grep 80
resource "system_service_systemd" "service" {
  depends_on = [
    null_resource.bin,
    system_file.config,
    system_file.htpasswd,
    system_file.cert,
    system_file.key,
    system_file.ca,
    system_link.data,
    system_file.service,
  ]
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
