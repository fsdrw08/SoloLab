resource "system_group" "group" {
  for_each = var.user
  name     = each.value.name
}

resource "system_user" "user" {
  for_each = var.user
  name     = each.value.name
  gid      = system_group.group[each.key].id
  shell    = "/bin/bash"
}

resource "system_folder" "home" {
  for_each = var.user
  path     = "/home/${each.value.name}"
  uid      = system_user.user[each.key].id
  gid      = system_group.group[each.key].id
}

resource "null_resource" "sudo" {
  depends_on = [system_user.user]
  for_each = {
    for k, v in var.user :
    k => v if v.sudo != null
  }
  triggers = {
    sudo = each.value.sudo
  }
  connection {
    type     = "ssh"
    host     = var.server.host
    user     = var.server.user
    password = var.server.password
  }
  provisioner "remote-exec" {
    inline = ["gpasswd --$(${each.value.sudo} && echo add || echo delete) ${each.value.name} sudo; sleep 1"]
  }
}

resource "null_resource" "chpasswd" {
  depends_on = [system_user.user]
  for_each = {
    for k, v in var.user :
    k => v if v.password != null
  }
  triggers = {
    password = each.value.password
  }
  connection {
    type     = "ssh"
    host     = var.server.host
    user     = var.server.user
    password = var.server.password
  }
  provisioner "remote-exec" {
    inline = ["echo '${each.value.name}:${each.value.password}' | chpasswd; sleep 1"]
  }
}
