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

# present minio server bin
resource "system_file" "server_bin" {
  path   = "${var.install.server.bin_file_dir}/minio"
  source = var.install.server.bin_file_source
  mode   = 755
}

# present minio server bin
resource "system_file" "client_bin" {
  count  = var.install.client == null ? 0 : 1
  path   = "${var.install.client.bin_file_dir}/mc"
  source = var.install.client.bin_file_source
  mode   = 755
}

# prepare minio config dir
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "700"
}

# persist minio config file in dir
resource "system_file" "env" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, basename(var.config.env.templatefile_path)])
  content    = templatefile(var.config.env.templatefile_path, var.config.env.templatefile_vars)
  user       = var.runas.user
  group      = var.runas.group
  mode       = "600"
}

resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.certs.sub_dir])
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
  path    = join("/", [system_folder.certs.path, "public.crt"])
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
  path    = join("/", [system_folder.certs.path, "private.key"])
  content = var.config.certs.key_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

# https://min.io/docs/minio/linux/operations/network-encryption.html#self-signed-internal-private-certificates-and-public-cas-with-intermediate-certificates
resource "system_folder" "ca" {
  depends_on = [
    system_folder.config
  ]
  path  = join("/", [system_folder.certs.path, "CAs"])
  user  = var.runas.user
  group = var.runas.group
  mode  = "700"
}

resource "system_file" "ca" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs,
    system_folder.ca
  ]
  path    = join("/", [system_folder.ca.path, var.config.certs.ca_basename])
  content = var.config.certs.ca_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
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
    system_file.server_bin,
    system_file.env,
    system_file.service,
  ]
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
