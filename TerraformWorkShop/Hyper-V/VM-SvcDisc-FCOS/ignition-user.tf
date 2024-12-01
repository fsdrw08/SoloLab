## config users
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

# enable lingering to make user level service able to auto start on boot
data "ignition_file" "rootless_linger" {
  path = "/var/lib/systemd/linger/podmgr"
  mode = 420 # oct 644 -> 420
  content {
    content = ""
  }
}

# set rootless user home dir to external disk
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

# create user level default.target.wants dir for service auto start
# https://docs.fedoraproject.org/en-US/fedora-coreos/tutorial-user-systemd-unit-on-boot/
data "ignition_directory" "user_config_systemd_user_defaultTargetWants" {
  path = "/home/podmgr/.config/systemd/user/default.target.wants"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
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

# enable podman socket (used by podman remote) for the user (rootless)
# link the socket in this dir for socket auto start when user login
# https://github.com/coreos/fedora-coreos-pipeline/blob/0a519b24de4e779a3e44eaaf1784993a3468b9b6/multi-arch-builders/builder-common.bu#L113
data "ignition_directory" "user_config_systemd_user_socketsTargetWants" {
  path = "/home/podmgr/.config/systemd/user/sockets.target.wants"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}

data "ignition_link" "rootless_podman_socket_unix_autostart" {
  # the link
  path = "/home/podmgr/.config/systemd/user/sockets.target.wants/podman.socket"
  # the source
  target    = "/usr/lib/systemd/user/podman.socket"
  overwrite = true
  uid       = 1001
  gid       = 1001
}

# stop container before machine shutdown
# https://askubuntu.com/questions/952363/how-do-i-properly-run-this-systemd-service-on-shutdown
# https://github.com/iree-org/iree/blob/65bbc4b4d56f3e752cc14fd8c8f53796a80bb0bf/build_tools/github_actions/runner/config/systemd/system/gh-runner-deregister.service#L12
data "ignition_file" "user_stop_container" {
  path = "/home/podmgr/.config/systemd/user/stop-container.service"
  mode = 420 # oct 644
  content {
    # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container
    # https://github.com/miabbott/fcos-cockpit/blob/3b0e432582f5513d8b5c9bfcf85a39b2d46fbd5c/etc/containers/systemd/cockpit.container#L6
    content = <<EOT
[Unit]
Description=Stop container before shutdown
DefaultDependencies=no
Before=halt.target poweroff.target shutdown.target reboot.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "for svc in $(ls /run/user/1001/systemd/generator/ | grep service); do systemctl --user stop $svc; done"
RemainAfterExit=yes

[Install]
WantedBy=halt.target poweroff.target shutdown.target reboot.target
EOT
  }
}

# create user level halt.target.wants dir for service auto run during this phase
# https://docs.fedoraproject.org/en-US/fedora-coreos/tutorial-user-systemd-unit-on-boot/
data "ignition_directory" "user_config_systemd_user_haltTargetWants" {
  path = "/home/podmgr/.config/systemd/user/halt.target.wants"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}
# link the user level stop container service to halt.target.wants for container service auto stop when halt
data "ignition_link" "user_stop_container_before_halt" {
  path      = "/home/podmgr/.config/systemd/user/halt.target.wants/stop-container.service"
  target    = data.ignition_file.user_stop_container.path
  overwrite = true
  hard      = false
  uid       = 1001
  gid       = 1001
}

# create user level poweroff.target.wants dir for service auto run during this phase
# https://docs.fedoraproject.org/en-US/fedora-coreos/tutorial-user-systemd-unit-on-boot/
data "ignition_directory" "user_config_systemd_user_poweroffTargetWants" {
  path = "/home/podmgr/.config/systemd/user/poweroff.target.wants"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}
# link the user level stop container service to poweroff.target.wants for service auto stop when poweroff
data "ignition_link" "user_stop_container_before_poweroff" {
  path      = "/home/podmgr/.config/systemd/user/poweroff.target.wants/stop-container.service"
  target    = data.ignition_file.user_stop_container.path
  overwrite = true
  hard      = false
  uid       = 1001
  gid       = 1001
}

# create user level shutdown.target.wants dir for service auto run during this phase
# https://docs.fedoraproject.org/en-US/fedora-coreos/tutorial-user-systemd-unit-on-boot/
data "ignition_directory" "user_config_systemd_user_shutdownTargetWants" {
  path = "/home/podmgr/.config/systemd/user/shutdown.target.wants"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}
# link the user level stop container service to shutdown.target.wants for service auto stop when shutdown
data "ignition_link" "user_stop_container_before_shutdown" {
  path      = "/home/podmgr/.config/systemd/user/shutdown.target.wants/stop-container.service"
  target    = data.ignition_file.user_stop_container.path
  overwrite = true
  hard      = false
  uid       = 1001
  gid       = 1001
}

# create user level reboot.target.wants dir for service auto run during this phase
# https://docs.fedoraproject.org/en-US/fedora-coreos/tutorial-user-systemd-unit-on-boot/
data "ignition_directory" "user_config_systemd_user_rebootTargetWants" {
  path = "/home/podmgr/.config/systemd/user/reboot.target.wants"
  mode = 493 # oct 755 -> dec 493
  uid  = 1001
  gid  = 1001
}
# link the user level stop container service to reboot.target.wants for service auto stop when reboot
data "ignition_link" "user_stop_container_before_reboot" {
  path      = "/home/podmgr/.config/systemd/user/reboot.target.wants/stop-container.service"
  target    = data.ignition_file.user_stop_container.path
  overwrite = true
  hard      = false
  uid       = 1001
  gid       = 1001
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
