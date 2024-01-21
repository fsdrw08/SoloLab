# stepca
# download stepca 
# https://smallstep.com/docs/step-ca/installation/#linux-binaries
resource "system_file" "stepca_tar" {
  source = var.stepca.install.server.tar_file_source
  path   = var.stepca.install.server.tar_file_path
}

# extract and put it to /usr/bin/
resource "null_resource" "stepca_bin" {
  depends_on = [system_file.stepca_tar]
  triggers = {
    file_source      = var.stepca.install.server.tar_file_source
    file_dir         = var.stepca.install.server.bin_file_dir
    strip_components = index(split("/", var.stepca.install.server.tar_file_bin_path), "step-ca")
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
      # https://smallstep.com/docs/step-ca/installation/#linux-binaries
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --extract --file=${system_file.stepca_tar.path} --directory=${var.stepca.install.server.bin_file_dir} --strip-components=${self.triggers.strip_components} --verbose --overwrite ${var.stepca.install.server.tar_file_bin_path}",
      "sudo chown 0:0 ${self.triggers.file_dir}/step-ca",
      "sudo chmod 755 ${self.triggers.file_dir}/step-ca",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/step-ca",
    ]
  }
}

resource "system_file" "stepcli_tar" {
  source = var.stepca.install.client.tar_file_source
  path   = var.stepca.install.client.tar_file_path
}

# extract and put it to /usr/bin/
resource "null_resource" "stepcli_bin" {
  depends_on = [system_file.stepcli_tar]
  triggers = {
    file_source      = var.stepca.install.client.tar_file_source
    file_dir         = var.stepca.install.client.bin_file_dir
    strip_components = index(split("/", var.stepca.install.client.tar_file_bin_path), "step")
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
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      # https://askubuntu.com/questions/45349/how-to-extract-files-to-another-directory-using-tar-command/470266#470266
      "sudo tar --extract --file=${system_file.stepcli_tar.path} --directory=${self.triggers.file_dir} --strip-components=${self.triggers.strip_components} --verbose --overwrite ${var.stepca.install.client.tar_file_bin_path}",
      "sudo chown 0:0 ${self.triggers.file_dir}/step",
      "sudo chmod 755 ${self.triggers.file_dir}/step",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/step",
    ]
  }
}

# prepare step-ca data dir
resource "system_link" "stepca_data" {
  path   = var.stepca.storage.dir_link
  target = var.stepca.storage.dir_target
  user   = var.stepca.runas.user
  group  = var.stepca.runas.group
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.stepca.storage.dir_target}",
      "sudo chown ${var.stepca.runas.user}:${var.stepca.runas.group} ${var.stepca.storage.dir_target}",
    ]
  }
}

# prepare step-ca init related env config
resource "system_file" "stepca_config" {
  path    = format("${var.stepca.config.file_path_dir}/%s", basename("${var.stepca.config.file_source}"))
  content = templatefile(var.stepca.config.file_source, var.stepca.config.vars)
}

# run step-ca init
resource "null_resource" "stepca_init" {
  depends_on = [
    null_resource.stepcli_bin,
    system_link.stepca_data,
    system_file.stepca_config
  ]
  count = var.stepca.init_script == null ? 0 : 1
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "export  $(grep -v '^#' ${system_file.stepca_config.path} | xargs)",
      file(var.stepca.init_script.file_source)
    ]
  }
}

# resource "system_file" "stepca_init_script" {
#   depends_on = [system_file.stepca_init_env]
#   path       = "/home/vyos/step-ca_entrypoint.sh"
#   content    = file("${path.module}/step-ca/entrypoint.sh")
#   connection {
#     type     = "ssh"
#     host     = var.vm_conn.host
#     port     = var.vm_conn.port
#     user     = var.vm_conn.user
#     password = var.vm_conn.password
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "mkdir -p /etc/step-ca/secrets",
#       "export  $(grep -v '^#' ${system_file.stepca_config.path} | xargs)",
#       "bash \"${system_file.stepca_init_script.path}\"",
#     ]
#   }
# }

# persist step-ca systemd unit file
resource "system_file" "stepca_service" {
  path    = var.stepca.service.systemd.file_path
  content = templatefile(var.stepca.service.systemd.file_source, var.stepca.service.systemd.vars)
}

resource "system_service_systemd" "stepca" {
  depends_on = [
    null_resource.stepca_bin,
    null_resource.stepca_init,
    system_file.stepca_service,
  ]
  name    = trimsuffix(system_file.stepca_service.basename, ".service")
  status  = var.stepca.service.status
  enabled = var.stepca.service.enabled
}

# https://developer.hashicorp.com/consul/tutorials/get-started-vms/virtual-machine-gs-service-discovery#modify-service-definition-tags
resource "system_file" "stepca_consul" {
  depends_on = [system_service_systemd.stepca]
  path       = "${system_folder.consul_config.path}/stepca.hcl"
  content    = file("./step-ca/step-ca_consul.hcl")
  user       = "vyos"
  group      = "users"
}
