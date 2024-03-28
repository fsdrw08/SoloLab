# traefik
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

# download traefik tar.gz
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
      # https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-binary-distribution
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --verbose --extract --file=${system_file.tar.path} --directory=${var.install.bin_file_dir} --overwrite",
      "sudo chmod 755 ${var.install.bin_file_dir}/traefik",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/traefik",
    ]
  }
}

# prepare traefik config dir
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "755"
}

# persist traefik static config file in dir
resource "system_file" "static" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.static.basename])
  content    = var.config.static.content
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

# presist traefik dynamic config sub dir
resource "system_folder" "dynamic" {
  depends_on = [system_folder.config]
  count      = var.config.dynamic == null ? 0 : 1
  path       = join("/", [var.config.dir, var.config.dynamic.sub_dir])
  user       = var.runas.user
  group      = var.runas.group
  mode       = "755"
}

# persist traefik dynamic config file in dir
resource "system_file" "dynamic" {
  depends_on = [system_folder.dynamic]
  for_each = {
    for file in var.config.dynamic.files : file.basename => file
  }
  path    = join("/", [var.config.dir, var.config.dynamic.sub_dir, each.value.basename])
  content = each.value.content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "755"
}

# presist traefik cert dir
resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.tls.sub_dir])
  user       = var.runas.user
  group      = var.runas.group
  mode       = "700"
}

resource "system_file" "ca" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [var.config.dir, var.config.tls.sub_dir, var.config.tls.ca_basename])
  content = var.config.tls.ca_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "cert" {
  count = var.config.tls.cert_basename == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
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
    system_folder.certs
  ]
  path    = join("/", [var.config.dir, var.config.tls.sub_dir, var.config.tls.key_basename])
  content = var.config.tls.key_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

# create and link traefik storage dir
resource "system_link" "data" {
  depends_on = [system_folder.config]
  path       = var.storage.dir_link
  target     = var.storage.dir_target
  user       = var.runas.user
  group      = var.runas.group
}

# persist traefik systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# debug service: journalctl -u traefik.service
# sudo netstat -apn | grep 80
resource "system_service_systemd" "service" {
  depends_on = [
    null_resource.bin,
    system_file.static,
    system_file.service,
  ]
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
