locals {
  # https://stackoverflow.com/questions/52628749/set-terraform-default-interpreter-for-local-exec
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

# minio
resource "null_resource" "minio_bin" {
  # source = "https://dl.min.io/server/minio/release/linux-amd64/minio"
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command = local.is_windows ? join(";",
      [
        "curl.exe -s -o ${path.module}/minio.bin https://dl.min.io/server/minio/release/linux-amd64/minio"
      ]
      ) : join(";",
      [
        "curl -s -o ${path.module}/minio.bin https://dl.min.io/server/minio/release/linux-amd64/minio"
      ]
    )
  }
}

data "null_data_source" "minio_bin" {
  inputs = {
    file = "${path.module}/minio.bin"
  }
}

resource "system_file" "minio_bin" {
  depends_on = [null_resource.minio_bin]
  path       = "/usr/local/bin/minio"
  source     = data.null_data_source.minio_bin.outputs.file
  mode       = 755
}

resource "system_file" "minio_service" {
  depends_on = [system_file.minio_bin]
  path       = "/usr/lib/systemd/system/minio.service"
  content = templatefile("${path.module}/minio.service.tftpl", {
    user  = "vyos",
    group = "users",
  })
  # source = "${path.module}/minio.service"
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

