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

# prepare zot config dir
resource "system_folder" "config" {
  path = var.config.dir
  uid  = var.runas.uid
  gid  = var.runas.gid
}

# persist zot config file in dir
resource "system_file" "config" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.main.basename])
  content    = var.config.main.content
  uid        = var.runas.uid
  gid        = var.runas.gid
}

resource "system_folder" "certs" {
  count      = var.config.tls == null ? 0 : 1
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.tls.sub_dir])
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "700"
}

resource "system_file" "ca" {
  count = var.config.tls == null ? 0 : var.config.tls.ca_content == null ? 0 : 1
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
