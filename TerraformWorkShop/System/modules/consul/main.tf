# consul
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

# download consul zip
resource "system_file" "zip" {
  source = var.install.zip_file_source
  path   = var.install.zip_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "bin" {
  depends_on = [system_file.zip]
  triggers = {
    file_source = var.install.zip_file_source
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
      "sudo unzip ${system_file.zip.path} -d ${var.install.bin_file_dir} -o",
      "sudo chmod 755 ${var.install.bin_file_dir}/consul",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.install.bin_file_dir}/vault"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/consul",
    ]
  }
}

# prepare vault config dir
resource "system_folder" "config" {
  path  = var.config.file_path_dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "700"
}

# persist vault config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  # path       = format("${var.config.file_path_dir}/%s", basename("${var.config.file_source}"))
  path    = join("/", ["${var.config.file_path_dir}", basename("${var.config.file_source}")])
  content = templatefile(var.config.file_source, var.config.vars)
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = join("/", ["${var.config.file_path_dir}", "${var.config.tls.sub_dir}"])
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
  path    = join("/", ["${var.config.file_path_dir}", "${var.config.tls.sub_dir}", "${var.config.tls.ca_basename}"])
  content = var.config.tls.ca_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "cert" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", ["${var.config.file_path_dir}", "${var.config.tls.sub_dir}", "${var.config.tls.cert_basename}"])
  content = var.config.tls.cert_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "key" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", ["${var.config.file_path_dir}", "${var.config.tls.sub_dir}", "${var.config.tls.key_basename}"])
  content = var.config.tls.key_content
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
  path    = var.service.systemd_unit_service.file_path
  content = templatefile(var.service.systemd_unit_service.file_source, var.service.systemd_unit_service.vars)
}

# sudo systemctl list-unit-files --type=service --state=disabled
# debug service: journalctl -u vault.service
# debug from boot log: journalctl -b
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
