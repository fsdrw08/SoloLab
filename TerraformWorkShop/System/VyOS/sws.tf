resource "system_file" "sws_tar" {
  source = var.sws.install.tar_file_source
  path   = var.sws.install.tar_file_path # "/usr/local/bin/"
}

# extra and put it to /usr/bin/
resource "null_resource" "sws_bin" {
  depends_on = [system_file.sws_tar]
  triggers = {
    file_source      = var.sws.install.tar_file_source
    file_dir         = var.sws.install.bin_file_dir
    strip_components = index(split("/", var.sws.install.tar_file_bin_path), "static-web-server")
    host             = var.vm_conn.host
    port             = var.vm_conn.port
    user             = var.vm_conn.user
    password         = sensitive(var.vm_conn.password)
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
      "sudo tar --extract --file=${system_file.sws_tar.path} --directory=${var.sws.install.bin_file_dir} --strip-components=1 --verbose --overwrite ${var.sws.install.tar_file_bin_path}",
      "sudo chmod 755 ${var.sws.install.bin_file_dir}/static-web-server",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.consul.install.bin_file_dir}/consul"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/static-web-server",
    ]
  }
}

# prepare consul config dir
resource "system_folder" "sws_config" {
  path = var.consul.config.file_path_dir
}

# persist consul config file in dir
resource "system_file" "sws_config" {
  depends_on = [system_folder.consul_config]
  path       = format("${var.consul.config.file_path_dir}/%s", basename("${var.consul.config.file_source}"))
  content    = templatefile(var.consul.config.file_source, var.consul.config.vars)
}
