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
  # why not put remote-exec provision with when destroy run "systemctl --user daemon-reload" here?
  # ref https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#destroy-time-provisioners
  # Destroy provisioners are run *before* the resource is destroyed
  # in order to remove the service which generate by quadlet here, the process should be:
  # remove the quadlet file first, then run "systemctl --user daemon-reload"
  # that's why we need add depends_on = [null_resource.quadlet_destroy] in this resource
  # and add provisioner step run "systemctl --user daemon-reload" when destroy in resource "null_resource.quadlet_destroy"
}

resource "null_resource" "service_mgmt" {
  depends_on = [remote_file.quadlet]
  triggers = {
    service_name = var.podman_quadlet.service.name
    quadlet_md5  = md5(join("\n", [for quadlet in remote_file.quadlet : quadlet.content]))
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
    inline = [
      "systemctl --user daemon-reload",
      "systemctl --user ${var.podman_quadlet.service.status} ${self.triggers.service_name}",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "systemctl --user stop ${self.triggers.service_name}",
    ]
  }
}
