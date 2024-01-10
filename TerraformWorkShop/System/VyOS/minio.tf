# minio
resource "system_file" "minio_bin" {
  path   = "${var.minio.install.server.bin_file_dir}/minio"
  source = var.minio.install.server.bin_file_source
  mode   = 755
}

resource "null_resource" "minio_data" {
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
  path    = var.minio.config.file_path
  content = templatefile(var.minio.config.file_source, var.minio.config.vars)
}

resource "system_file" "minio_service" {
  depends_on = [system_file.minio_bin]
  path       = var.minio.service.minio.systemd_unit_service.file_path
  content = templatefile(
    var.minio.service.minio.systemd_unit_service.file_source,
    var.minio.service.minio.systemd_unit_service.vars
  )
}

# sudo systemctl list-unit-files --type=service --state=disabled
# journalctl -u minio.service
resource "system_service_systemd" "minio" {
  depends_on = [
    system_file.minio_bin,
    system_file.minio_conf,
    system_file.minio_service,
  ]
  name    = trimsuffix(system_file.minio_service.basename, ".service")
  status  = var.minio.service.minio.status
  enabled = var.minio.service.minio.enabled
}

# persist minio restart systemd service unit file
resource "system_file" "minio_restart_service" {
  path = var.minio.service.minio_restart.systemd_unit_service.file_path
  content = templatefile(
    var.minio.service.minio_restart.systemd_unit_service.file_source,
    var.minio.service.minio_restart.systemd_unit_service.vars
  )
}

# persist minio restart systemd path unit file
resource "system_file" "minio_restart_path" {
  path = var.minio.service.minio_restart.systemd_unit_path.file_path
  content = templatefile(
    var.minio.service.minio_restart.systemd_unit_path.file_source,
    var.minio.service.minio_restart.systemd_unit_path.vars
  )
}

resource "null_resource" "minio_restart_path" {
  depends_on = [
    system_file.minio_restart_path,
  ]
  triggers = {
    unit_name = system_file.minio_restart_path.basename
    host      = var.vm_conn.host
    port      = var.vm_conn.port
    user      = var.vm_conn.user
    password  = sensitive(var.vm_conn.password)
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
      "sleep 5",
      "sudo systemctl enable ${self.triggers.unit_name} --now",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl disable ${self.triggers.unit_name} --now",
    ]
  }
}

# https://github.com/minio/minio/issues/12992
# present CAs sub folder is a must when 
# hosting minio behind a reservers proxy with self sign cert
resource "system_folder" "minio_certs" {
  path  = var.minio_certs.dir
  user  = var.minio.runas.user
  group = var.minio.runas.group
}

resource "system_link" "minio_CAs" {
  depends_on = [system_folder.minio_certs]
  path       = var.minio_certs.CAs_dir_link
  target     = var.minio_certs.CAs_dir_target
  user       = var.minio.runas.user
  group      = var.minio.runas.group
}

resource "system_file" "minio_consul" {
  depends_on = [
    system_service_systemd.minio,
  ]
  path    = "${system_folder.consul_config.path}/minio.hcl"
  content = file("./minio/minio_consul.hcl")
  user    = "vyos"
  group   = "users"
}
