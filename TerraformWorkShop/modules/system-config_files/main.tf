resource "system_folder" "parent" {
  path = var.config.dir
  uid  = var.owner.uid
  gid  = var.owner.gid
}

resource "system_file" "file" {
  depends_on = [system_folder.parent]
  for_each = {
    for file in var.config.files : file.basename => file
  }
  path    = join("/", [var.config.dir, each.value.basename])
  content = each.value.content
  uid     = var.owner.uid
  gid     = var.owner.gid
  mode    = each.value.mode
}

resource "system_folder" "secret" {
  depends_on = [system_folder.parent]
  for_each = {
    for secret in var.config.secrets : secret.sub_dir => secret
  }
  path = join("/", [var.config.dir, each.value.sub_dir])
  uid  = var.owner.uid
  gid  = var.owner.gid
}

locals {
  secret_files = flatten([
    for secret in var.config.secrets : [
      for file in secret.files : {
        path    = join("/", [var.config.dir, secret.sub_dir, file.basename])
        content = file.content
        mode    = file.mode
      }
    ]
  ])
}

resource "system_file" "secret" {
  depends_on = [system_folder.secret]
  for_each = {
    for file in local.secret_files : file.path => file
  }
  path    = each.value.path
  content = each.value.content
  uid     = var.owner.uid
  gid     = var.owner.gid
  mode    = each.value.mode
}
