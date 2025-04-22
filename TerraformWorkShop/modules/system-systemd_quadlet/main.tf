resource "null_resource" "quadlet_destroy" {
  # In order to prevent e.g. dependency cycles, Terraform 
  # does not allow destroy time remote-exec when connection 
  # attributes (e.g. host, user, ...) is owned by a different
  # resource the provisioners is added to.
  # Connections are not available from null_resource.
  # Therefore, we're adding triggers which allow us to
  # reference connection attributes from self.triggers.
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
  # why put remote-exec provision with `when = destroy` run "systemctl --user daemon-reload" here?
  # ref https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#destroy-time-provisioners
  # Destroy provisioners are run *before* the resource is destroyed
  # in order to remove the service which generate by quadlet here, the process should be:
  # remove the quadlet file first, then run "systemctl --user daemon-reload"
  # that's why we need add depends_on = [null_resource.quadlet_destroy] in below resource "remote_file.quadlet" 
  # and add provisioner step run "systemctl --user daemon-reload" in `when = destroy` in this resource "null_resource.quadlet_destroy"
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user daemon-reload",
    ]
  }
}

# https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#kube-units-kube
resource "remote_file" "quadlet" {
  depends_on = [null_resource.quadlet_destroy]
  for_each = {
    for file in var.podman_quadlet.files : file.path => file
  }
  content = each.value.content
  path    = each.value.path
}

resource "null_resource" "service_stop" {
  depends_on = [remote_file.quadlet]
  triggers = {
    service_name = var.podman_quadlet.service.name
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

resource "null_resource" "service_mgmt" {
  count = var.podman_quadlet.service == null ? 0 : 1
  depends_on = [
    remote_file.quadlet,
    null_resource.service_stop
  ]
  triggers = {
    service_name   = var.podman_quadlet.service.name
    service_status = var.podman_quadlet.service.status
    quadlet_md5    = md5(join("\n", [for quadlet in remote_file.quadlet : quadlet.content]))
    custom_trigger = var.podman_quadlet.service.custom_trigger
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
      if [ "${var.podman_quadlet.service.status}" = "start" ]; then
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
      elif [ "${var.podman_quadlet.service.status}" = "stop" ]; then
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
