# coredns
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

resource "system_packages_apt" "apt" {
  for_each = {
    for package in var.install : package => package
  }
  package {
    name = each.value.package
  }
}

# prepare powerdns authoritative server config dir
resource "system_folder" "config" {
  path = var.config.dir
  uid  = var.runas.uid
  gid  = var.runas.gid
}

resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.main.basename])
  content    = var.config.main.content
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = var.config.main.mode
}
