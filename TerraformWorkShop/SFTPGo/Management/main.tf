resource "sftpgo_folder" "folder" {
  for_each = {
    for folder in var.virtual_folders : folder.name => folder
  }
  name        = each.value.name
  mapped_path = each.value.mapped_path
  filesystem  = each.value.filesystem
}

resource "sftpgo_group" "group" {
  depends_on = [sftpgo_folder.folder]
  for_each = {
    for group in var.groups : group.name => group
  }
  name = each.value.name
  user_settings = {
    filesystem = each.value.user_settings.filesystem
    home_dir   = each.value.user_settings.home_dir
  }
  virtual_folders = each.value.virtual_folders
}
