#!/bin/ash
set -euxo pipefail

# https://github.com/rgl/alpine-vagrant/blob/master/install.sh
firmware="$([ -d /sys/firmware/efi ] && echo 'uefi' || echo 'bios')"
boot_device='/dev/sda'

# install to local disk.
echo 'root:root' | chpasswd
cat >answers <<EOF
KEYMAPOPTS="us us"
HOSTNAMEOPTS="-n alpine"
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
"
DNSOPTS=""
TIMEZONEOPTS="-z PRC"
PROXYOPTS="none"
APKREPOSOPTS="https://mirrors.ustc.edu.cn/alpine/v3.16/main/
https://mirrors.ustc.edu.cn/alpine/v3.16/community/
https://mirrors.ustc.edu.cn/alpine/edge/testing/"
SSHDOPTS="-c openssh"
NTPOPTS="-c chrony"
DISKOPTS="-s 0 -m sys $boot_device"
EOF
ERASE_DISKS="$boot_device" setup-alpine -e -f $PWD/answers

# force the firmware to boot from disk. no need for hyper-v
# if [ "$firmware" == 'uefi' ]; then
#     echo "apk add efibootmgr"
#     apk add efibootmgr
#     efibootmgr -o 0002
# fi

# configure sshd to allow root login.
mount "${boot_device}2" /mnt
sed -i -E 's,#?(PermitRootLogin\s+).+,\1yes,' /mnt/etc/ssh/sshd_config


# reboot to the installed system.
reboot