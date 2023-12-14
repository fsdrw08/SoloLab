# traefik
# download traefik tar.gz
resource "system_file" "traefik_tar" {
  path   = "/home/vyos/traefik.tar.gz"
  source = "https://github.com/traefik/traefik/releases/download/${var.traefik_version}/traefik_${var.traefik_version}_linux_amd64.tar.gz"
}

# unzip and put it to /usr/bin/
resource "null_resource" "traefik_bin" {
  depends_on = [system_file.traefik_tar]
  triggers = {
    traefik_version = var.traefik_version
    host            = var.vm_conn.host
    port            = var.vm_conn.port
    user            = var.vm_conn.user
    password        = sensitive(var.vm_conn.password)
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
      # https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-binary-distribution
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --verbose --extract --file=${system_file.traefik_tar.path} --directory=/usr/local/bin/ --overwrite",
      "sudo chmod 755 /usr/local/bin/traefik",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f /usr/local/bin/traefik",
    ]
  }
}
