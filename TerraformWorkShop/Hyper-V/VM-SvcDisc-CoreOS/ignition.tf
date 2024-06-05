# # config rclone config
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


# generate podman container and related systemd config with quadlet
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

