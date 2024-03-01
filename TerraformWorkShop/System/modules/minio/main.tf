# minio
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

# download minio bin
resource "system_file" "bin" {
  path   = "${var.install.server.bin_file_dir}/minio"
  source = var.install.server.bin_file_source
  mode   = 755
}

# prepare minio config dir
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "700"
}

# persist vault config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, basename(var.config.main.templatefile_path)])
  content    = templatefile(var.config.main.templatefile_path, var.config.main.templatefile_vars)
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

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
  count = var.config.tls == null ? 0 : 1
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
  count = var.config.tls == null ? 0 : 1
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
  path    = var.service.systemd_unit_service.target_path
  content = templatefile(var.service.systemd_unit_service.templatefile_path, var.service.systemd_unit_service.templatefile_vars)
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
