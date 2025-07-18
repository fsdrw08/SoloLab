# nomad
resource "system_group" "group" {
  count = var.runas.take_charge == true ? 1 : 0
  name  = var.runas.group
}

resource "system_user" "user" {
  count      = var.runas.take_charge == true ? 1 : 0
  depends_on = [system_group.group]
  name       = var.runas.user
  group      = var.runas.group
}

# download nomad zip
resource "system_file" "zip" {
  source = var.install.zip_file_source
  path   = var.install.zip_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "bin" {
  depends_on = [system_file.zip]
  triggers = {
    file_source = var.install.zip_file_source
    file_dir    = var.install.bin_file_dir
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
      "unzip -o ${system_file.zip.path} nomad -d ${var.install.bin_file_dir}",
      "chmod 755 ${var.install.bin_file_dir}/nomad",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.install.bin_file_dir}/vault"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user daemon-reload",
      "rm -f ${self.triggers.file_dir}/nomad",
    ]
  }
}

# persist nomad config file in dir
resource "system_file" "config" {
  path    = join("/", [var.config.dir, basename(var.config.main.basename)])
  content = var.config.main.content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

# persist nomad systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# debug service: journalctl -u nomad.service
# sudo netstat -apn | grep 80
# resource "system_service_systemd" "service" {
#   depends_on = [
#     null_resource.bin,
#     system_file.config,
#     system_file.service,
#   ]
#   name    = trimsuffix(system_file.service.basename, ".service")
#   status  = var.service.status
#   enabled = var.service.enabled
# }


# this resource is only in charge to stop the service when tf resource destroy
resource "null_resource" "service_stop" {
  triggers = {
    service_name = trimsuffix(system_file.service.basename, ".service")
    host         = var.vm_conn.host
    port         = var.vm_conn.port
    user         = var.vm_conn.user
    password     = sensitive(var.vm_conn.password)
    private_key  = sensitive(var.vm_conn.private_key)
  }
  connection {
    type        = "ssh"
    host        = self.triggers.host
    port        = self.triggers.port
    user        = self.triggers.user
    password    = self.triggers.password
    private_key = self.triggers.private_key
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user stop ${self.triggers.service_name}",
    ]
  }
}

# this resource is in charge to start/restart service if the trigger status change, 
# or stop the service if the value of service state set to stop, 
# but NOT to stop the service when the tf resource destroy, to stop the service when destroy, use null_resource.service_stop
resource "null_resource" "service_mgmt" {
  depends_on = [
    null_resource.bin,
    system_file.config,
    system_file.service,
  ]
  triggers = {
    service_name   = trimsuffix(system_file.service.basename, ".service")
    service_status = var.service.status
    config_md5     = system_file.config.md5sum
    bin_md5        = system_file.zip.md5sum
  }
  connection {
    type        = "ssh"
    host        = var.vm_conn.host
    port        = var.vm_conn.port
    user        = var.vm_conn.user
    password    = sensitive(var.vm_conn.password)
    private_key = sensitive(var.vm_conn.private_key)
  }
  provisioner "remote-exec" {
    inline = [
      <<-EOF
      systemctl --user daemon-reload
      if [ "${self.triggers.service_status}" = "start" ]; then
          service_status=$(systemctl --user is-active ${self.triggers.service_name})
          if [ "$service_status" != "active" ]; then
              echo "${self.triggers.service_name} is stop, start it"
              systemctl --user start ${self.triggers.service_name}
          elif [ "$service_status" = "active" ]; then
              echo "${self.triggers.service_name} is start, restart it"
              systemctl --user restart ${self.triggers.service_name}
          else
              echo "${self.triggers.service_name} status unknown"
          fi
      elif [ "${self.triggers.service_status}" = "stop" ]; then
          echo "stop ${self.triggers.service_name}"
          systemctl --user stop ${self.triggers.service_name}
      else
          echo "var $status invalid, should 'start' or 'stop'"
      fi
      EOF
      ,
    ]
  }
}
