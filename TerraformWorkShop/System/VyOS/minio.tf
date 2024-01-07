# minio
resource "system_file" "minio_bin" {
  path   = "/usr/local/bin/minio"
  source = var.minio.install.bin_file_source
  mode   = 755
}

resource "system_link" "minio_data" {
  path   = var.minio.storage.dir_link
  target = var.minio.storage.dir_target
  user   = var.minio.runas.user
  group  = var.minio.runas.group
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.minio.storage.dir_target}",
      "sudo chown ${var.minio.runas.user}:${var.minio.runas.group} ${var.minio.storage.dir_target}",
    ]
  }
}

# https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html#create-the-systemd-service-file
resource "system_file" "minio_conf" {
  path   = format("${var.minio.config.file_path_dir}/%s", basename("${var.minio.config.file_source}")) # "/etc/default/minio"
  source = templatefile(var.minio.config.file_source, var.minio.config.vars)
}

resource "system_file" "minio_service" {
  depends_on = [system_file.minio_bin]
  path       = var.minio.service.systemd_unit_service.file_path # "/usr/lib/systemd/system/minio.service"
  content    = templatefile(var.minio.service.systemd_unit_service.file_source, var.minio.service.systemd_unit_service.var)
}


# sudo systemctl list-unit-files --type=service --state=disabled
# journalctl -u minio.service
resource "system_service_systemd" "minio" {
  depends_on = [
    system_file.minio_bin,
    system_file.minio_service,
  ]
  name    = trimsuffix(system_file.minio_service.basename, ".service")
  status  = var.minio.service.status
  enabled = var.minio.service.enabled
}

