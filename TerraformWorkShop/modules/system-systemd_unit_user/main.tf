# ref: https://www.freedesktop.org/software/systemd/man/latest/systemd.path.html#:~:text=For%20each%20path,(see%20below).
# this resource is only in charge to stop the service when tf resource destroy
resource "null_resource" "service_remove" {
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
      "systemctl --user daemon-reload",
    ]
  }
}

# persist systemd unit files
resource "system_file" "service" {
  depends_on = [
    null_resource.service_remove
  ]
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
  uid     = var.runas.uid
  gid     = var.runas.gid
}

resource "system_link" "service" {
  depends_on = [
    system_file.service,
  ]
  count  = var.service.auto_start.enabled == true ? 1 : 0
  path   = var.service.auto_start.link_path
  target = var.service.auto_start.link_target
  uid    = var.runas.uid
  gid    = var.runas.gid
}

# this resource is only in charge to stop the service when tf resource destroy
resource "null_resource" "service_stop" {
  depends_on = [system_file.service]
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
    system_file.service,
    null_resource.service_stop,
    system_link.service
  ]
  triggers = {
    service_name    = trimsuffix(system_file.service.basename, ".service")
    service_status  = var.service.status
    service_content = md5(system_file.service.content)
    config_md5      = md5(system_file.config.content)
    bin_url         = md5(join("\n", [for file in system_file.zip : file.path]))
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
