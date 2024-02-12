# vault
# download vault zip
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
      "sudo chmod 755 ${var.install.bin_file_dir}/vault",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.install.bin_file_dir}/vault"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/vault",
    ]
  }
}

# prepare vault config dir
resource "system_folder" "config" {
  path = var.config.file_path_dir
}

# persist vault config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = format("${var.config.file_path_dir}/%s", basename("${var.config.file_source}"))
  content    = templatefile(var.config.file_source, var.config.vars)
}

resource "system_link" "data" {
  path   = var.storage.dir_link
  target = var.storage.dir_target
  user   = var.runas.user
  group  = var.runas.group
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.storage.dir_target}",
      "sudo chown ${var.runas.user}:${var.runas.group} ${var.storage.dir_target}",
    ]
  }
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
