# lldap
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

# download lldap tar
resource "system_file" "tar" {
  source = var.install.tar_file_source
  path   = var.install.tar_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "bin" {
  depends_on = [system_file.tar]
  triggers = {
    bin_file_dir         = var.install.bin_file_dir
    strip_components_bin = index(split("/", var.install.tar_file_bin_path), "lldap")
    app_pkg_dir          = var.install.app_pkg_dir
    strip_components_app = index(split("/", var.install.tar_file_app_path), "app")
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
      # https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-binary-distribution
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --extract --file=${system_file.tar.path} --directory=${var.install.bin_file_dir} --strip-components=${self.triggers.strip_components_bin} --verbose --overwrite ${var.install.tar_file_bin_path}",
      "sudo chmod 755 ${var.install.bin_file_dir}/lldap",
      "sudo mkdir -p ${var.install.app_pkg_dir}",
      "sudo tar --extract --file=${system_file.tar.path} --directory=${var.install.app_pkg_dir} --strip-components=${self.triggers.strip_components_bin + 1} --verbose --overwrite --wildcards ${var.install.tar_file_app_path}*",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.bin_file_dir}/lldap",
      "sudo rm -rf ${self.triggers.app_pkg_dir}",
    ]
  }
}

# prepare lldap config dir
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "700"
}

# persist lldap config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, basename(var.config.main.basename)])
  content    = var.config.main.content
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

resource "system_file" "env" {
  count      = var.config.env == null ? 0 : 1
  depends_on = [system_folder.config]
  path       = join("/", ["${var.config.dir}", basename("${var.config.env.basename}")])
  content    = var.config.env.content
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}"])
  user       = var.runas.user
  group      = var.runas.group
  mode       = "700"
}

resource "system_file" "cert" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}", "${var.config.certs.cert_basename}"])
  content = var.config.certs.cert_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "key" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}", "${var.config.certs.key_basename}"])
  content = var.config.certs.key_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_link" "data" {
  path   = var.storage.dir_link
  target = var.storage.dir_target
  user   = var.runas.user
  group  = var.runas.group
}

# persist systemd unit file
# https://developer.hashicorp.com/vault/tutorials/operations/production-hardening
# https://github.com/hashicorp/vault/blob/main/.release/linux/package/usr/lib/systemd/system/vault.service
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# sudo systemctl list-unit-files --type=service --state=disabled
# debug service: journalctl -u vault.service
# debug from boot log: journalctl -b
resource "system_service_systemd" "service" {
  depends_on = [
    null_resource.bin,
    system_file.config,
    system_link.data,
    system_file.service,
  ]
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
