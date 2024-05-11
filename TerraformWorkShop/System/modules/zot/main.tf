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
  group      = var.runas.group
}

# present zot server bin
resource "system_file" "server_bin" {
  count  = var.install.server == null ? 0 : 1
  path   = "${var.install.server.bin_file_dir}/zot"
  source = var.install.server.bin_file_source
  mode   = 755
}

resource "null_resource" "bin" {
  count      = var.install.server == null ? 0 : 1
  depends_on = [system_file.server_bin]
  triggers = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = sensitive(var.vm_conn.password)
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl daemon-reload",
    ]
  }
}

# present zot client bin
resource "system_file" "client_bin" {
  count  = var.install.client == null ? 0 : 1
  path   = "${var.install.client.bin_file_dir}/zli"
  source = var.install.client.bin_file_source
  mode   = 755
}

# prepare zot config dir
resource "system_folder" "config" {
  path = var.config.dir
  uid  = var.runas.uid
  gid  = var.runas.gid
  mode = "755"
}

# persist zot config file in dir
resource "system_file" "main" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.main.basename])
  content    = var.config.main.content
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "644"
}

resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, var.config.certs.sub_dir])
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "755"
}

resource "system_file" "cacert" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs.path, var.config.certs.cacert_basename])
  content = var.config.certs.cacert_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

resource "system_file" "cert" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs.path, var.config.certs.cert_basename])
  content = var.config.certs.cert_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

resource "system_file" "key" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", [system_folder.certs.path, var.config.certs.key_basename])
  content = var.config.certs.key_content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "600"
}

