# CockroachDB
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

# download CockroachDB tgz (tar.gz)
resource "system_file" "tar" {
  source = var.install.tar_file_source
  path   = var.install.tar_file_path
}

# extract and put it to /usr/local/bin
# https://www.cockroachlabs.com/docs/stable/install-cockroachdb-linux#install-binary
resource "null_resource" "bin" {
  depends_on = [system_file.tar]
  triggers = {
    bin_file_dir         = var.install.bin_file_dir
    strip_components_bin = index(split("/", var.install.tar_file_bin_path), "cockroach")
    ext_lib_dir          = var.install.ext_lib_dir
    strip_components_lib = index(split("/", var.install.tar_file_lib_path), "lib")
    host                 = var.vm_conn.host
    port                 = var.vm_conn.port
    user                 = var.vm_conn.user
    password             = sensitive(var.vm_conn.password)
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
      # https://www.cockroachlabs.com/docs/releases/
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --verbose --extract --file=${system_file.tar.path} --directory=${var.install.bin_file_dir} --strip-components=${self.triggers.strip_components_bin} --overwrite ${var.install.tar_file_bin_path}",
      "sudo chmod 755 ${var.install.bin_file_dir}/cockroach",
      "sudo mkdir -p ${var.install.ext_lib_dir}", # mkdir -p /usr/local/lib/cockroach
      "sudo tar --verbose --extract --file=${system_file.tar.path} --directory=${var.install.ext_lib_dir} --strip-components=${self.triggers.strip_components_lib + 1} --overwrite --wildcards ${var.install.tar_file_lib_path}*",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl daemon-reload",
      "sudo rm -f ${self.triggers.bin_file_dir}/cockroach",
      "sudo rm -rf ${self.triggers.ext_lib_dir}",
    ]
  }
}

# prepare CockroachDB config dir
resource "system_folder" "config" {
  path  = var.config.dir
  user  = var.runas.user
  group = var.runas.group
  mode  = "755"
}

resource "system_folder" "certs" {
  depends_on = [system_folder.config]
  count      = var.config.certs == null ? 0 : 1
  path       = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}"])
  user       = var.runas.user
  group      = var.runas.group
  mode       = "755"
}

resource "system_file" "ca_cert" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}", "ca.crt"])
  content = var.config.certs.ca_cert_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "644"
}

resource "system_file" "node_cert" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path = join("/", [
    "${var.config.dir}",
    "${var.config.certs.sub_dir}",
    "node.crt"
    ]
  )
  content = var.config.certs.node_cert_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "node_key" {
  count = var.config.certs == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path = join("/", [
    "${var.config.dir}",
    "${var.config.certs.sub_dir}",
    "node.key"
    ]
  )
  content = var.config.certs.node_key_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "client_cert" {
  count = var.config.certs == null && var.config.certs.client_cert_content == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path    = join("/", ["${var.config.dir}", "${var.config.certs.sub_dir}", "${var.config.certs.client_cert_basename}"])
  content = var.config.certs.client_cert_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

resource "system_file" "client_key" {
  count = var.config.certs == null && var.config.certs.client_key_content == null ? 0 : 1
  depends_on = [
    system_folder.config,
    system_folder.certs
  ]
  path = join("/", [
    "${var.config.dir}",
    "${var.config.certs.sub_dir}",
    "${var.config.certs.client_key_basename}"
    ]
  )
  content = var.config.certs.client_key_content
  user    = var.runas.user
  group   = var.runas.group
  mode    = "600"
}

# persist CockroachDB systemd unit file
resource "system_file" "service" {
  path    = var.service.systemd_service_unit.path
  content = var.service.systemd_service_unit.content
}

# debug service: journalctl -u CockroachDB.service
# sudo netstat -apn | grep 80
resource "system_service_systemd" "service" {
  depends_on = [
    null_resource.bin,
    system_file.ca_cert,
    system_file.node_cert,
    system_file.node_key,
    system_file.service,
  ]
  name    = trimsuffix(system_file.service.basename, ".service")
  status  = var.service.status
  enabled = var.service.enabled
}
