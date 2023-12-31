# traefik
# download traefik tar.gz
resource "system_file" "traefik_tar" {
  source = var.traefik.install.tar_file_source
  path   = var.traefik.install.tar_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "traefik_bin" {
  depends_on = [system_file.traefik_tar]
  triggers = {
    file_source = var.traefik.install.tar_file_source
    file_dir    = var.traefik.install.bin_file_dir
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
      # https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-binary-distribution
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --verbose --extract --file=${system_file.traefik_tar.path} --directory=${var.traefik.install.bin_file_dir} --overwrite",
      "sudo chmod 755 ${var.traefik.install.bin_file_dir}/traefik",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/traefik",
    ]
  }
}

# prepare traefik config dir
resource "system_folder" "traefik_config" {
  path = var.traefik.config.file_path_dir
}

# persist consul config file in dir
resource "system_file" "traefik_config" {
  depends_on = [system_folder.traefik_config]
  path       = format("${var.traefik.config.file_path_dir}/%s", basename("${var.consul.config.file_source}"))
  content    = templatefile(var.traefik.config.file_source, var.consul.config.vars)
}

resource "system_link" "traefik_data" {
  depends_on = [system_folder.traefik_config]
  path       = var.traefik.storage.dir_link
  target     = var.traefik.storage.dir_target
  user       = var.traefik.runas.user
  group      = var.traefik.runas.group
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.traefik.storage.dir_target}",
      "sudo chown ${var.traefik.runas.user}:${var.traefik.runas.group} ${var.traefik.storage.dir_target}",
    ]
  }
}

# persist traefik systemd unit file
resource "system_file" "consul_service" {
  path    = var.consul.service.systemd.file_path
  content = templatefile(var.consul.service.systemd.file_source, var.consul.service.systemd.vars)
}
