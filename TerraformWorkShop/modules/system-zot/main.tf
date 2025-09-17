# zot user group
resource "system_group" "group" {
  count = var.runas.take_charge == true ? 1 : 0
  name  = var.runas.group
  gid   = var.runas.gid
}

resource "system_user" "user" {
  count      = var.runas.take_charge == true ? 1 : 0
  depends_on = [system_group.group]
  name       = var.runas.user
  uid        = var.runas.uid
  gid        = var.runas.gid
}

resource "system_file" "bin" {
  for_each = {
    for install in var.install : install.bin_file_source => install
  }
  source = each.value.bin_file_source
  path   = "${each.value.bin_file_dir}/${each.value.bin_file_name}"
  mode   = 755
}
