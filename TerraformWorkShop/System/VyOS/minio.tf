# minio
resource "system_file" "minio_bin" {
  path   = "/usr/local/bin/minio"
  source = "https://dl.min.io/server/minio/release/linux-amd64/minio"
  mode   = 755
}

resource "system_file" "minio_service" {
  depends_on = [system_file.minio_bin]
  path       = "/usr/lib/systemd/system/minio.service"
  content = templatefile("${path.module}/minio/minio.service.tftpl",
    {
      user  = "vyos",
      group = "users",
    }
  )
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload"
    ]
  }
}

# https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html#create-the-systemd-service-file
resource "system_file" "minio_data" {
  path    = "/etc/default/minio"
  content = <<-EOT
MINIO_OPTS='--console-address "192.168.255.2:9001"'
MINIO_VOLUMES="/mnt/data/minio"
MINIO_SERVER_URL="http://192.168.255.2:9000"
EOT
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /mnt/data/minio",
      "sudo chown vyos:users /mnt/data/minio",
    ]
  }
}

# sudo systemctl list-unit-files --type=service --state=disabled
# journalctl -u minio.service
resource "system_service_systemd" "minio" {
  depends_on = [system_file.minio_service]
  name       = "minio"
  status     = "started" # stopped started
  enabled    = true
}

