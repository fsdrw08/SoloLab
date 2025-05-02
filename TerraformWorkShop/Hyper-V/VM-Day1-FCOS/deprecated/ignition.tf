# generate ignition file content
data "ignition_config" "ignition" {
  count       = local.count
  disks       = [data.ignition_disk.data.rendered]
  filesystems = [data.ignition_filesystem.data.rendered]
  systemd = [
    data.ignition_systemd_unit.data.rendered,
    data.ignition_systemd_unit.rpm_ostree.rendered
  ]
  directories = [
    data.ignition_directory.user_home.rendered,
    data.ignition_directory.user_config.rendered,
    data.ignition_directory.user_config_systemd.rendered,
    data.ignition_directory.user_config_systemd_user.rendered,
    data.ignition_directory.user_config_systemd_user_defaultTargetWants.rendered,
    data.ignition_directory.user_config_systemd_user_haltTargetWants.rendered,
    data.ignition_directory.user_config_systemd_user_poweroffTargetWants.rendered,
    data.ignition_directory.user_config_systemd_user_shutdownTargetWants.rendered,
    data.ignition_directory.user_config_systemd_user_rebootTargetWants.rendered,
    data.ignition_directory.user_config_containers.rendered,
    data.ignition_directory.user_config_containers_systemd.rendered,
  ]
  users = [
    data.ignition_user.core.rendered,
    data.ignition_user.user.rendered
  ]
  files = [
    data.ignition_file.hostname[count.index].rendered,
    data.ignition_file.disable_dhcp.rendered,
    data.ignition_file.eth0[count.index].rendered,
    # data.ignition_file.hashicorp_repo.rendered,
    data.ignition_file.mirror_fedora_repo.rendered,
    data.ignition_file.mirror_fedora_updates_repo.rendered,
    data.ignition_file.disable_cisco_repo.rendered,
    data.ignition_file.disable_fedora_updates_archive_repo.rendered,
    data.ignition_file.rpms.rendered,
    data.ignition_file.rootless_linger.rendered,
    data.ignition_file.rootless_podman_socket_tcp_service.rendered,
    data.ignition_file.enable_password_auth.rendered,
    data.ignition_file.sysctl_unprivileged_port.rendered,
  ]
  links = [
    data.ignition_link.timezone.rendered,
    data.ignition_link.rootless_podman_socket_unix_autostart.rendered,
    data.ignition_link.user_stop_container_before_halt.rendered,
    data.ignition_link.user_stop_container_before_poweroff.rendered,
    data.ignition_link.user_stop_container_before_shutdown.rendered,
    data.ignition_link.user_stop_container_before_reboot.rendered,
    # if dont want to expose podman tcp socket, just comment below line
    # data.ignition_link.rootless_podman_socket_tcp_autostart.rendered,
  ]
}

# config rclone config
# data "ignition_directory" "rclone_conf_dir" {
#   path = "/home/podmgr/.config/rclone"
#   mode = 493 # oct 755 -> dec 493
#   uid  = 1001
#   gid  = 1001
# }

# data "ignition_file" "rclone_conf" {
#   path      = "/home/podmgr/.config/rclone/rclone.conf"
#   mode      = 420 # oct 644 -> dec 420
#   overwrite = true
#   uid       = 1001
#   gid       = 1001
#   content {
#     content = <<EOT
# [minio]
# type = s3
# provider = Minio
# env_auth = false
# access_key_id = minio
# secret_access_key = miniosecret
# region = main
# endpoint = http://192.168.255.1:9000
# location_constraint =
# server_side_encryption =
# EOT
#   }
# }


# # generate podman container and related systemd config with quadlet
# data "ignition_file" "cockpit" {
#   path = "/etc/containers/systemd/cockpit-ws.container"
#   mode = 420 # oct 644
#   content {
#     # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container
#     # https://github.com/miabbott/fcos-cockpit/blob/3b0e432582f5513d8b5c9bfcf85a39b2d46fbd5c/etc/containers/systemd/cockpit.container#L6
#     content = <<EOT
# [Unit]
# Description=Cockpit container
# After=local-fs.target

# [Container]
# Environment=TZ=${var.fcos_timezone}
# Image=quay.io/cockpit/ws
# PublishPort=9090:9090

# [Install]
# WantedBy=multi-user.target default.target
# EOT
#   }
# }
