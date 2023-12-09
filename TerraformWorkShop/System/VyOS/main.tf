resource "system_file" "nfs_ganesha" {
  path = "/etc/ganesha/ganesha.conf.new"
  content = templatefile("${path.module}/ganesha.conf.tftpl", {
    export_path = "/mnt/data/nfs",
  })
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cp /etc/ganesha/ganesha.conf.new /etc/ganesha/ganesha.conf",
    ]
  }
}

resource "system_service_systemd" "nfs_ganesha" {
  name    = "nfs-ganesha"
  enabled = true
  status  = "started"
}

resource "system_file" "minio_deb" {
  path   = "/home/vyos/minio1.deb"
  source = "https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20231207041600.0.0_amd64.deb"
}

resource "null_resource" "minio_dpkg" {
  triggers = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = sensitive(var.vm_conn.password)
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
      "sudo dpkg -i /home/vyos/minio1.deb",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo dpkg --remove minio"
    ]
  }
}

resource "system_group" "minio" {
  name = "minio-user"
  gid  = 1005
}

resource "system_user" "minio" {
  name  = "minio-user"
  uid   = 1005
  group = system_group.minio.name
  home  = "/home/minio-user"
}

resource "system_folder" "minio_home" {
  path = "/home/minio-user"
  user = system_user.minio.name
}

resource "system_file" "minio_data" {
  path    = "/etc/default/minio"
  content = <<-EOT
MINIO_VOLUMES="/mnt/data/minio"
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
      "sudo chown 1005:1005 /mnt/data/minio"
    ]
  }
}

# sudo systemctl list-unit-files --type=service --state=disabled
resource "system_service_systemd" "minio" {
  name    = "minio"
  status  = "started"
  enabled = true
}

