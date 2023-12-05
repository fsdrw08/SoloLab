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

data "system_command" "chpasswd" {
  depends_on = [system_user.user]
  for_each   = var.user
  command    = "echo '${each.value.name}:${each.value.password}' | chpasswd"
}

data "system_command" "sudo" {
  depends_on = [system_user.user]
  for_each   = var.user
  command    = "usermod -aG sudo ${each.value.name}"
}
