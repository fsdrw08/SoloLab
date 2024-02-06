# vault
# download vault zip
resource "system_file" "vault_zip" {
  source = var.vault.install.zip_file_source
  path   = var.vault.install.zip_file_path # "/usr/bin/vault"
}

# unzip and put it to /usr/bin/
resource "null_resource" "vault_bin" {
  depends_on = [system_file.vault_zip]
  triggers = {
    file_source = var.vault.install.zip_file_source
    file_dir    = var.vault.install.bin_file_dir
    host        = var.vm_conn.host
    port        = var.vm_conn.port
    user        = var.vm_conn.user
    password    = sensitive(var.vm_conn.password)
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
      "sudo unzip ${system_file.vault_zip.path} -d ${var.vault.install.bin_file_dir} -o",
      "sudo chmod 755 ${var.vault.install.bin_file_dir}/vault",
      # https://superuser.com/questions/710253/allow-non-root-process-to-bind-to-port-80-and-443
      # "sudo setcap CAP_NET_BIND_SERVICE=+eip ${var.vault.install.bin_file_dir}/vault"
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f ${self.triggers.file_dir}/vault",
    ]
  }
}

# prepare vault config dir
resource "system_folder" "vault_config" {
  path = var.vault.config.file_path_dir
}

# persist vault config file in dir
resource "system_file" "vault_config" {
  depends_on = [system_folder.vault_config]
  path       = format("${var.vault.config.file_path_dir}/%s", basename("${var.vault.config.file_source}"))
  content    = templatefile(var.vault.config.file_source, var.vault.config.vars)
}

resource "system_link" "vault_data" {
  path   = var.vault.storage.dir_link
  target = var.vault.storage.dir_target
  user   = var.vault.runas.user
  group  = var.vault.runas.group
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${var.vault.storage.dir_target}",
      "sudo chown ${var.vault.runas.user}:${var.vault.runas.group} ${var.vault.storage.dir_target}",
    ]
  }
}

resource "tls_cert_request" "vault" {
  private_key_pem = tls_private_key.root.private_key_pem

  dns_names = [
    "vault.service.consul",
  ]

  subject {
    common_name  = "vault.service.consul"
    organization = "Sololab"
  }
}

resource "tls_locally_signed_cert" "vault" {
  cert_request_pem   = tls_cert_request.vault.cert_request_pem
  ca_private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  validity_period_hours = (5 * 365 * 24) # 5 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "system_file" "vault_tls" {
  path = var.vault.tls.cert_file
  content = format("%s\n%s", tls_locally_signed_cert.vault.cert_pem,
  tls_self_signed_cert.root.cert_pem)
}
