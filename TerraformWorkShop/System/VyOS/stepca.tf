# stepca
# download stepca 
# https://smallstep.com/docs/step-ca/installation/#linux-binaries
resource "system_file" "stepca_tar" {
  path   = "/home/vyos/step-ca_linux_amd64.tar.gz"
  source = "https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_linux_amd64.tar.gz"
  #   source = "https://dl.smallstep.com/gh-release/certificates/gh-release-header/v${var.stepca_version}/step-ca_linux_${var.stepca_version}_amd64.tar.gz"
}

# extract and put it to /usr/bin/
resource "null_resource" "stepca_bin" {
  depends_on = [system_file.stepca_tar]
  triggers = {
    stepca_version = var.stepca_version
    host           = var.vm_conn.host
    port           = var.vm_conn.port
    user           = var.vm_conn.user
    password       = sensitive(var.vm_conn.password)
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
      # https://smallstep.com/docs/step-ca/installation/#linux-binaries
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      "sudo tar --extract --file=${system_file.stepca_tar.path} --directory=/usr/bin/ --strip-components=1 --verbose --overwrite step-ca_linux_amd64/step-ca",
      "sudo chmod 755 /usr/bin/step-ca",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f /usr/bin/step-ca",
    ]
  }
}


resource "system_file" "stepcli_tar" {
  path   = "/home/vyos/step_linux_amd64.tar.gz"
  source = "https://dl.smallstep.com/cli/docs-cli-install/latest/step_linux_amd64.tar.gz"
  #   source = "https://dl.smallstep.com/gh-release/cli/gh-release-header/v${var.stepcli_version}/step_linux_${var.stepcli_version}_amd64.tar.gz"
}

# extract and put it to /usr/bin/
resource "null_resource" "stepcli_bin" {
  depends_on = [system_file.stepcli_tar]
  triggers = {
    stepcli_version = var.stepcli_version
    host            = var.vm_conn.host
    port            = var.vm_conn.port
    user            = var.vm_conn.user
    password        = sensitive(var.vm_conn.password)
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
      # https://www.man7.org/linux/man-pages/man1/tar.1.html
      # https://askubuntu.com/questions/45349/how-to-extract-files-to-another-directory-using-tar-command/470266#470266
      "sudo tar --extract --file=${system_file.stepcli_tar.path} --directory=/usr/bin/ --strip-components=2 --verbose --overwrite step_linux_amd64/bin/step",
      "sudo chmod 755 /usr/bin/step",
    ]
  }
  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f /usr/bin/step",
    ]
  }
}

resource "system_link" "stepca_path" {
  depends_on = [
    null_resource.stepca_bin,
    null_resource.stepcli_bin
  ]
  path   = "/etc/step-ca"
  target = "/mnt/data/step-ca/"
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /mnt/data/step-ca",
      "sudo chown vyos:users /mnt/data/step-ca",
    ]
  }
}

resource "system_file" "stepca_init_env" {
  depends_on = [system_link.stepca_path]
  path       = "/home/vyos/step-ca.env"
  content    = <<-EOT
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
    STEPPATH="/etc/step-ca"
    PWDPATH="/etc/step-ca/secrets/password"
    DOCKER_STEPCA_INIT_NAME="sololab"
    DOCKER_STEPCA_INIT_ACME="true"
    DOCKER_STEPCA_INIT_DNS_NAMES="localhost,step-ca.service.consul"
    DOCKER_STEPCA_INIT_SSH="true"
    DOCKER_STEPCA_INIT_REMOTE_MANAGEMENT="true"
    DOCKER_STEPCA_INIT_PROVISIONER_NAME="admin"
    DOCKER_STEPCA_INIT_PASSWORD=${var.stepca_password}
  EOT
}

resource "system_file" "stepca_init_script" {
  depends_on = [system_file.stepca_init_env]
  path       = "/home/vyos/step-ca_entrypoint.sh"
  content    = file("${path.module}/step-ca/entrypoint.sh")
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/step-ca/secrets",
      "export  $(grep -v '^#' ${system_file.stepca_init_env.path} | xargs)",
      "bash \"${system_file.stepca_init_script.path}\"",
    ]
  }
}

# persist step-ca systemd unit file
resource "system_file" "stepca_service" {
  depends_on = [system_file.stepca_init_env]
  path       = "/etc/systemd/system/step-ca.service"
  content = templatefile("${path.module}/step-ca/step-ca.service.tftpl", {
    user  = "vyos",
    group = "users",
  })
}
