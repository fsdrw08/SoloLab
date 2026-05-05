# https://docs.fedoraproject.org/en-US/fedora-coreos/hostname/
data "ignition_file" "hostname" {
  count = local.count
  path  = "/etc/hostname"
  mode  = 420 # OCT: 0644
  content {
    content = local.count <= 1 ? "${var.vm_name}" : "${var.vm_name}${count.index + 1}" # 
  }
}

# https://docs.fedoraproject.org/en-US/fedora-coreos/time-zone/
data "ignition_link" "timezone" {
  path   = "/etc/localtime"
  target = "../usr/share/zoneinfo/${var.fcos_timezone}"
}

## config global service
# By default, Fedora CoreOS does not allow password authentication via SSH.
# In order to use cockpit with password login, so enable password auth
#
# Source: https://docs.fedoraproject.org/en-US/fedora-coreos/authentication/#_enabling_ssh_password_authentication
data "ignition_file" "enable_password_auth" {
  path = "/etc/ssh/sshd_config.d/20-enable-passwords.conf"
  mode = 420 # oct 644 -> dec 420
  content {
    content = <<EOT
# Fedora CoreOS disables SSH password login by default.
# Enable it.
# This file must sort before 40-disable-passwords.conf.
PasswordAuthentication yes
EOT
  }
}

# low down the unprivilege port
data "ignition_file" "sysctl_unprivileged_port" {
  path = "/etc/sysctl.d/90-unprivileged_port_start.conf"
  content {
    content = <<-EOT
      net.ipv4.ip_unprivileged_port_start = 53
    EOT
  }
}
