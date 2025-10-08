# ref: https://www.freedesktop.org/software/systemd/man/latest/systemd.path.html#:~:text=For%20each%20path,(see%20below).
# this resource is only in charge to stop the service when tf resource destroy
resource "null_resource" "unit_remove" {
  triggers = {
    host        = var.vm_conn.host
    port        = var.vm_conn.port
    user        = var.vm_conn.user
    password    = sensitive(var.vm_conn.password)
    private_key = sensitive(var.vm_conn.private_key)
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
resource "system_file" "unit" {
  depends_on = [
    null_resource.unit_remove
  ]
  for_each = {
    for unit in var.units : unit.file.path => unit
  }
  content = each.value.file.content
  path    = each.value.file.path
}

resource "system_link" "service" {
  depends_on = [
    system_file.unit,
  ]
  for_each = {
    for unit in var.units : unit.file.path => unit
    if unit.auto_start.enabled == true
  }
  path   = each.value.auto_start.link_path
  target = each.value.auto_start.link_target
}

# this resource is only in charge to stop the service when tf resource destroy
resource "null_resource" "unit_stop" {
  depends_on = [system_file.unit]
  for_each = {
    for unit in var.units : unit.file.path => unit
  }
  triggers = {
    unit_name   = basename(each.value.file.path)
    host        = var.vm_conn.host
    port        = var.vm_conn.port
    user        = var.vm_conn.user
    password    = sensitive(var.vm_conn.password)
    private_key = sensitive(var.vm_conn.private_key)
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
      "systemctl --user stop ${self.triggers.unit_name}",
    ]
  }
}

# this resource is in charge to start/restart service if the trigger status change, 
# or stop the service if the value of service state set to stop, 
# but NOT to stop the service when the tf resource destroy, to stop the service when destroy, use null_resource.unit_stop
resource "null_resource" "unit_mgmt" {
  depends_on = [
    null_resource.unit_stop
  ]
  for_each = {
    for unit in var.units : unit.file.path => unit
    if unit.status != ""
  }
  triggers = {
    unit_name    = basename(each.value.file.path)
    unit_status  = each.value.status
    unit_content = each.value.file.content
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
      if [ "${each.value.status}" = "start" ]; then
          unit_status=$(systemctl --user is-active ${self.triggers.unit_name})
          if [ "$unit_status" != "active" ]; then
              echo "${self.triggers.unit_name} is stop, start it"
              systemctl --user start ${self.triggers.unit_name}
          elif [ "$unit_status" = "active" ]; then
              echo "${self.triggers.unit_name} is start, restart it"
              systemctl --user restart ${self.triggers.unit_name}
          else
              echo "${self.triggers.unit_name} status unknown"
          fi
      elif [ "${each.value.status}" = "stop" ]; then
          echo "stop ${self.triggers.unit_name}"
          systemctl --user stop ${self.triggers.unit_name}
      else
          echo "var \$status is not 'start' nor 'stop', skip"
      fi
      EOF
      ,
    ]
  }
}
