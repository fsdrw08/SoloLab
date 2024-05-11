# opendj
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

# download opendj tar
resource "system_file" "zip" {
  count  = var.install == null ? 0 : 1
  source = var.install.zip_file_source
  path   = var.install.zip_file_path
}

# unzip and put it to /usr/bin/
resource "null_resource" "bin" {
  count      = var.install == null ? 0 : 1
  depends_on = [system_file.zip]
  triggers = {
    unzip_dir = var.install.unzip_dir
    host      = var.vm_conn.host
    port      = var.vm_conn.port
    user      = var.vm_conn.user
    password  = sensitive(var.vm_conn.password)
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    inline = [
      # https://github.com/OpenIdentityPlatform/OpenDJ/wiki/Installation-Guide#to-install-opendj-directory-server-from-the-command-line
      "sudo unzip ${system_file.zip[0].path} -d ${var.install.unzip_dir} -o",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl daemon-reload",
      "sudo rm -rf ${self.triggers.target_dir}",
    ]
  }
}

# prepare opendj config dir
resource "system_folder" "config" {
  path = var.config.dir
  uid  = var.runas.uid
  gid  = var.runas.gid
  mode = "755"
}

# persist opendj properties file for setup phase in dir
# https://github.com/OpenIdentityPlatform/OpenDJ/wiki/Installation-Guide#to-install-opendj-directory-server-with-a-properties-file
resource "system_file" "properties" {
  depends_on = [system_folder.config]
  path       = join("/", [var.config.dir, basename(var.config.properties.basename)])
  content    = var.config.properties.content
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "644"
}

resource "system_folder" "schema" {
  count      = var.config.schema == null ? 0 : 1
  depends_on = [system_folder.config]
  path       = join("/", ["${var.config.dir}", "${var.config.schema.sub_dir}"])
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "755"
}

resource "system_file" "ldif" {
  depends_on = [
    system_folder.config,
    system_folder.schema
  ]
  for_each = {
    for ldif in var.config.schema.ldif : ldif.basename => ldif
  }
  path    = join("/", ["${var.config.dir}", "${var.config.schema.sub_dir}", "${each.value.basename}"])
  content = each.value.content
  uid     = var.runas.uid
  gid     = var.runas.gid
  mode    = "644"
}


resource "system_folder" "certs" {
  count      = var.config.certs == null ? 0 : 1
  depends_on = [system_folder.config]
  path       = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}"])
  uid        = var.runas.uid
  gid        = var.runas.gid
  mode       = "755"
}

resource "system_file" "cert" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path   = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}", "${var.config.certs.basename}"])
  source = var.config.certs.source
  uid    = var.runas.uid
  gid    = var.runas.gid
  mode   = "755"
}

resource "system_link" "data" {
  count  = var.storage == null ? 0 : 1
  path   = var.storage.dir_link
  target = var.storage.dir_target
  user   = var.runas.uid
  group  = var.runas.gid
}

# persist systemd unit file
# https://developer.hashicorp.com/vault/tutorials/operations/production-hardening
# https://github.com/hashicorp/vault/blob/main/.release/linux/package/usr/lib/systemd/system/vault.service
# resource "system_file" "service" {
#   path    = var.service.systemd_service_unit.path
#   content = var.service.systemd_service_unit.content
# }

# # sudo systemctl list-unit-files --type=service --state=disabled
# # debug service: journalctl -u vault.service
# # debug from boot log: journalctl -b
# resource "system_service_systemd" "service" {
#   depends_on = [
#     null_resource.bin,
#     system_file.config,
#     system_link.data,
#     system_file.service,
#   ]
#   name    = trimsuffix(system_file.service.basename, ".service")
#   status  = var.service.status
#   enabled = var.service.enabled
# }
