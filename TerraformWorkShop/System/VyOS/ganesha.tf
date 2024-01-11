resource "system_file" "nfs_ganesha" {
  path = "/etc/ganesha/ganesha.conf.new"
  content = templatefile("${path.module}/ganesha/ganesha.conf.tftpl", {
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

