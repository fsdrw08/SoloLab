# nomad
resource "system_group" "group" {
  count = var.runas.take_charge == true ? 1 : 0
  name  = var.runas.group
}

resource "system_user" "user" {
  count      = var.runas.take_charge == true ? 1 : 0
  depends_on = [system_group.group]
  name       = var.runas.user
  uid        = var.runas.uid
  gid        = var.runas.gid
}

# download nomad zip
resource "system_file" "zip" {
  for_each = {
    for install in var.install : install.zip_file_path => install
  }
  source = each.value.zip_file_source
  path   = each.value.zip_file_path
  uid    = var.runas.uid
  gid    = var.runas.gid
}

# unzip and put it to ${each.value.bin_file_dir}
resource "null_resource" "bin" {
  depends_on = [system_file.zip]
  for_each = {
    for install in var.install : install.zip_file_path => install
  }
  triggers = {
    file_source   = each.value.zip_file_source
    file_dir      = each.value.bin_file_dir
    bin_file_name = each.value.bin_file_name
    host          = var.vm_conn.host
    port          = var.vm_conn.port
    user          = var.vm_conn.user
    password      = sensitive(var.vm_conn.password)
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
      "/usr/bin/bsdtar -x -f ${each.value.zip_file_path} -C ${each.value.bin_file_dir} ${each.value.bin_file_name}",
      "chmod +x ${each.value.bin_file_dir}/${each.value.bin_file_name}",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.install.bin_file_dir}/vault"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user daemon-reload",
      "rm -f ${self.triggers.file_dir}/${self.triggers.bin_file_name}",
    ]
  }
}

# prepare nomad config dir
resource "system_folder" "config" {
  count = var.config.create_dir == true ? 1 : 0
  path  = var.config.dir
  uid   = var.runas.uid
  gid   = var.runas.gid
}

# persist nomad config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, basename(var.config.main.basename)])
  content    = var.config.main.content
  uid        = var.runas.uid
  gid        = var.runas.gid
}


resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  count      = var.config.tls == null ? 0 : 1
  path       = join("/", [var.config.dir, var.config.tls.sub_dir])
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "700"
}

resource "system_file" "ca" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs[0].path, var.config.tls.ca_basename])
  content = var.config.tls.ca_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

resource "system_file" "cert" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs[0].path, var.config.tls.cert_basename])
  content = var.config.tls.cert_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

resource "system_file" "key" {
  count = var.config.tls == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs[0].path, var.config.tls.key_basename])
  content = var.config.tls.key_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

# persist nomad systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
  uid     = var.runas.uid
  gid     = var.runas.gid
}

resource "system_link" "service" {
  depends_on = [system_file.service]
  count      = var.service.auto_start.enabled == true ? 1 : 0
  path       = var.service.auto_start.link_path
  target     = var.service.auto_start.link_target
  uid        = var.runas.uid
  gid        = var.runas.gid
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
    null_resource.bin,
    system_file.config,
    system_file.ca,
    system_file.cert,
    system_file.key,
    system_file.service,
    null_resource.service_stop
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
