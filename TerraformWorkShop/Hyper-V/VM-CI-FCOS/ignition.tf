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

# mount nfs
data "ignition_directory" "mnt_nfs" {
  path = "/var/mnt/data"
}

# this ignition terraform provider does not provide filesystems.with_mount_unit like butane
# https://coreos.github.io/butane/config-fcos-v1_5/
# had to create the systemd mount unit manually
# to debug, run journalctl --unit var-mnt-data.mount -b-boot
# https://github.com/getamis/terraform-ignition-etcd/blob/6526ce743d36f7950e097dabbff4ccfb41655de7/volume.tf#L28
# https://github.com/meyskens/vagrant-coreos-baremetal/blob/5470c582fa42f499bc17eb501d3e592cf85caaf1/terraform/modules/ignition/systemd/files/data.mount.tpl
# https://unix.stackexchange.com/questions/225401/how-to-see-full-log-from-systemctl-status-service/225407#225407
data "ignition_systemd_unit" "data" {
  # mind the unit name, The .mount file must be named based on the mount point path (e.g. /var/mnt/data = var-mnt-data.mount)
  # https://docs.fedoraproject.org/en-US/fedora-coreos/storage/#_configuring_nfs_mounts
  name    = "var-mnt-data.mount"
  content = <<EOT
[Unit]
Description=Mount nfs share
Before=local-fs.target

[Mount]
What=192.168.255.1:/mnt/data/nfs
Where=/var/mnt/data
Type=nfs4

[Install]
WantedBy=multi-user.target
EOT
}

# config static ip
# https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration/#_disabling_automatic_configuration_of_ethernet_devices
data "ignition_file" "disable_dhcp" {
  path      = "/etc/NetworkManager/conf.d/noauto.conf"
  mode      = 420
  overwrite = true
  content {
    content = <<EOT
[main]
# Do not do automatic (DHCP/SLAAC) configuration on ethernet devices
# with no other matching connections.
no-auto-default=*
EOT
  }
}

# https://docs.fedoraproject.org/en-US/fedora-coreos/sysconfig-network-configuration/#_configuring_a_static_ip
data "ignition_file" "eth0" {
  count     = local.count
  path      = "/etc/NetworkManager/system-connections/eth0.nmconnection"
  mode      = 384
  overwrite = true
  content {
    content = <<EOT
[connection]
id=eth0
type=ethernet
interface-name=eth0

[ipv4]
method=manual
addresses=192.168.255.1${count.index + 0}
gateway=192.168.255.1
dns=192.168.255.1
EOT
  }
}

# set core user password and ssh key
data "ignition_user" "core" {
  name = "core"
  groups = [
    "wheel",
    "sudo"
  ]
  # to gen password hash
  # https://docs.fedoraproject.org/en-US/fedora-coreos/authentication/#_using_password_authentication
  password_hash = "$y$j9T$cDLwsV9ODTV31Dt4SuVGa.$FU0eRT9jawPhIV3IV24W7obZ3PaJuBCVp7C9upDCcgD"
  ssh_authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
  ]
}

# set rootless user password and ssh key
data "ignition_user" "user" {
  name          = "podmgr"
  uid           = 1001
  password_hash = "$y$j9T$I4IXP5reKRLKrkwuNjq071$yHlJulSZGzmyppGbdWHyFHw/D8Gl247J2J8P43UnQWA"
  ssh_authorized_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
  ]
}

# set rootless user home dir
data "ignition_directory" "user_home" {
  path = "/var/home/podmgr"
  mode = 448 # oct 700 -> dec 448
  uid  = 1001
  gid  = 1001
}

data "ignition_directory" "user_config" {
  path = "/home/podmgr/.config"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}

data "ignition_directory" "user_config_systemd" {
  path = "/home/podmgr/.config/systemd"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}

data "ignition_directory" "user_config_systemd_user" {
  path = "/home/podmgr/.config/systemd/user"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}

# create user level default.target.wants dir for service auto start
# https://docs.fedoraproject.org/en-US/fedora-coreos/tutorial-user-systemd-unit-on-boot/
data "ignition_directory" "user_config_systemd_user_defaultTargetWants" {
  path = "/home/podmgr/.config/systemd/user/default.target.wants"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}

# enable podman socket (used by podman remote) for the user (rootless)
# link the socket in this dir for socket auto start when user login
# https://github.com/coreos/fedora-coreos-pipeline/blob/0a519b24de4e779a3e44eaaf1784993a3468b9b6/multi-arch-builders/builder-common.bu#L113
data "ignition_link" "rootless_podman_socket_unix_autostart" {
  # the link
  path = "/home/podmgr/.config/systemd/user/sockets.target.wants/podman.socket"
  # the source
  target    = "/usr/lib/systemd/user/podman.socket"
  overwrite = true
  uid       = 1001
  gid       = 1001
}

# create user level systemd service to expose podman socket to external tcp port
# https://github.com/openstack/tripleo-ansible/blob/e281ae7624774d71f22fbb993af967ed1ec08780/tripleo_ansible/roles/tripleo_podman/templates/podman.service.j2#L11
data "ignition_file" "rootless_podman_socket_tcp_service" {
  path      = "/home/podmgr/.config/systemd/user/podman-socket-tcp.service"
  mode      = 420 # oct 644 -> dec 420
  overwrite = true
  uid       = 1001
  gid       = 1001
  content {
    content = <<EOT
[Unit]
Description=Podman API Service (TCP)
Requires=podman.socket
After=podman.socket
Documentation=man:podman-system-service(1)
StartLimitIntervalSec=0

[Service]
Delegate=true
Type=exec
KillMode=process
Environment=LOGGING="--log-level=info"
ExecStart=/usr/bin/podman $LOGGING system service --time=0 tcp://0.0.0.0:2375

[Install]
WantedBy=default.target
EOT
  }
}

# link the user level podman tcp socket service to default.target.wants for service auto start when login
data "ignition_link" "rootless_podman_socket_tcp_autostart" {
  path      = "/home/podmgr/.config/systemd/user/default.target.wants/podman-socket-tcp.service"
  target    = data.ignition_file.rootless_podman_socket_tcp_service.path
  overwrite = true
  hard      = false
  uid       = 1001
  gid       = 1001
}

# enable lingering to make user level service able to auto start on boot
data "ignition_file" "rootless_linger" {
  path = "/var/lib/systemd/linger/podmgr"
  mode = 420 # oct 644 -> 420
  content {
    content = ""
  }
}

# install packages
# prepare yum repo
# data "ignition_file" "hashicorp_repo" {
#   path = "/etc/yum.repos.d/hashicorp.repo"
#   mode = 420 # oct 644 -> dec 420
#   # source {
#   #   source = "https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
#   # }
#   # or
#   content {
#     content = <<EOT
# [hashicorp]
# name=Hashicorp Stable - $basearch
# baseurl=https://rpm.releases.hashicorp.com/fedora/$releasever/$basearch/stable
# enabled=1
# gpgcheck=1
# gpgkey=https://rpm.releases.hashicorp.com/gpg
#   EOT
#   }
# }

# https://cockpit-project.org/running.html#coreos
# https://github.com/coreos/fedora-coreos-tracker/issues/681
data "ignition_file" "rpms" {
  path = "/etc/systemd/system/rpm-ostree-install.service.d/rpms.conf"
  mode = 420 # oct 644 -> dec 420
  content {
    content = <<EOT
[Service]
Environment=RPMS="cockpit-system cockpit-ostree cockpit-podman cockpit-networkmanager"
EOT
  }
}

data "ignition_systemd_unit" "rpm_ostree" {
  name    = "rpm-ostree-install.service"
  enabled = true
  content = <<EOT
[Unit]
Description=Layer additional rpms
Wants=network-online.target
After=network-online.target
# We run before `zincati.service` to avoid conflicting rpm-ostree transactions.
Before=zincati.service
ConditionPathExists=!/var/lib/%N.stamp
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/rpm-ostree install --apply-live --allow-inactive $RPMS
ExecStart=/bin/touch /var/lib/%N.stamp
[Install]
WantedBy=multi-user.target
EOT
}

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

# config podman quadlet
# https://www.redhat.com/sysadmin/multi-container-application-podman-quadlet
data "ignition_directory" "user_config_containers" {
  path = "/home/podmgr/.config/containers"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}

data "ignition_directory" "user_config_containers_systemd" {
  path = "/home/podmgr/.config/containers/systemd"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}

# config consul
# https://discussion.fedoraproject.org/t/installing-and-running-consul-on-coreos/72526
data "ignition_file" "consul_bin" {
  path = "/usr/local/bin/consul"
  source {
    source = "tftp://192.168.255.1/bin/consul"
  }
}

data "ignition_user" "consul" {
  name     = "consul"
  system   = true
  home_dir = "/etc/consul.d"
  shell    = "/bin/false"
  uid      = 1002
}

data "ignition_directory" "consul_config" {
  path = "/etc/consul.d"
  mode = 493 # oct 755 -> 493
  uid  = 1002
  gid  = 1002
}

data "ignition_file" "consul_config" {
  path = "/etc/consul.d/consul.hcl"
  mode = 483 # oct 666 -> 483
  uid  = 1002
  gid  = 1002
  content {
    content = <<-EOT
    acl {
      tokens {
        # https://developer.hashicorp.com/consul/docs/agent/config/config-files#acl_tokens_default
        default = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
      }
    }
    auto_reload_config = true
    bind_addr = "{{ GetInterfaceIP `eth0` }}"
    datacenter = "dc1"
    data_dir = "/opt/consul"
    encrypt = "qDOPBEr+/oUVeOFQOnVypxwDaHzLrD+lvjo5vCEBbZ0="
    retry_join = [
      "consul.service.consul"
    ]
    EOT
  }
}

data "ignition_directory" "consul_data" {
  path = "/opt/consul"
  mode = 493 # oct 755 -> dec 493
  uid  = 1002
  gid  = 1002
}

data "ignition_systemd_unit" "consul" {
  name    = "consul.service"
  enabled = true
  content = <<-EOT
    [Unit]
    Description="HashiCorp Consul - A service mesh solution"
    Documentation=https://www.consul.io/
    Requires=network-online.target
    After=network-online.target
    ConditionFileNotEmpty=/etc/consul.d/consul.hcl

    [Service]
    User=consul
    Group=consul
    Type=notify
    ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
    ExecReload=/bin/kill --signal HUP $MAINPID
    KillMode=process
    KillSignal=SIGTERM
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target
  EOT
}

# generate podman container and related systemd config with quadlet
data "ignition_file" "cockpit" {
  path = "/etc/containers/systemd/cockpit-ws.container"
  mode = 420 # oct 644
  content {
    # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container
    # https://github.com/miabbott/fcos-cockpit/blob/3b0e432582f5513d8b5c9bfcf85a39b2d46fbd5c/etc/containers/systemd/cockpit.container#L6
    content = <<EOT
[Unit]
Description=Cockpit container
After=local-fs.target

[Container]
Environment=TZ=${var.fcos_timezone}
Image=quay.io/cockpit/ws
PublishPort=9090:9090

[Install]
WantedBy=multi-user.target default.target
EOT
  }
}

