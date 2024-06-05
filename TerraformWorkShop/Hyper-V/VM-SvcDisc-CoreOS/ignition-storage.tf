# setup external disk
data "ignition_disk" "data" {
  device     = "/dev/sdb"
  wipe_table = false
  partition {
    number  = 1
    label   = "data"
    sizemib = 0
  }
}

data "ignition_filesystem" "data" {
  device          = "/dev/disk/by-partlabel/data"
  format          = "xfs"
  wipe_filesystem = false
  label           = "data"
  path            = "/var/home/podmgr"
}

# the ignition provider does not provide filesystems.with_mount_unit like butane
# https://coreos.github.io/butane/config-fcos-v1_5/
# had to create the systemd mount unit manually
# to debug, run journalctl --unit var-home-podmgr.mount -b-boot
# https://github.com/getamis/terraform-ignition-etcd/blob/6526ce743d36f7950e097dabbff4ccfb41655de7/volume.tf#L28
# https://github.com/meyskens/vagrant-coreos-baremetal/blob/5470c582fa42f499bc17eb501d3e592cf85caaf1/terraform/modules/ignition/systemd/files/data.mount.tpl
# https://unix.stackexchange.com/questions/225401/how-to-see-full-log-from-systemctl-status-service/225407#225407
data "ignition_systemd_unit" "data" {
  # mind the unit name, The .mount file must be named based on the mount point path (e.g. /var/mnt/data = var-mnt-data.mount)
  # https://docs.fedoraproject.org/en-US/fedora-coreos/storage/#_configuring_nfs_mounts
  name    = "var-home-podmgr.mount"
  content = <<EOT
[Unit]
Description=Mount data disk
Before=local-fs.target

[Mount]
What=/dev/disk/by-partlabel/data
Where=/var/home/podmgr
Type=xfs
DirectoryMode=0700

[Install]
RequiredBy=local-fs.target
EOT
}
