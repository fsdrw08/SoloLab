resource "sftpgo_folder" "folder" {

}

resource "sftpgo_group" "group" {
  for_each = {
    for group in var.groups : group.name => group
  }
  name = each.value.name
  user_settings = {
    filesystem = {
      provider = each.value.user_settings.filesystem.provider
    }
    home_dir = each.value.user_settings.home_dir
  }
  virtual_folders = each.value.virtual_folders
}
