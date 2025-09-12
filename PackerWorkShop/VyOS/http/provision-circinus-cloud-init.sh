#!/bin/bash
# ref: https://github.com/vyos/vyos-vm-images/blob/07825901d1ebb483ac6edc39e0a4c224fad82638/roles/install-cloud-init/tasks/main.yml
# https://dev.packages.vyos.net/
# Put debian.list
touch /etc/apt/sources.list.d/debian.list
cat <<EOF >>/etc/apt/sources.list.d/debian.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
deb https://rolling-packages.vyos.net/current current main
EOF

# apt-get update
apt-get update

# Install cloud-init
# apt-get install -t current -y --force-yes cloud-init cloud-utils ifupdown jq yq nfs-ganesha nfs-ganesha-vfs 
apt-get install -t current -y cloud-init cloud-utils ifupdown jq yq

# stop and disable nfs-ganesha
# systemctl disable nfs-ganesha

# apt-get clean
apt-get clean

# delete apt lists from cache
rm -rf /var/lib/apt/lists/

# Delete debian.list
rm /etc/apt/sources.list.d/debian.list

# Put datasource_list.cfg
touch /etc/cloud/cloud.cfg.d/90_dpkg.cfg
cat <<EOF >>/etc/cloud/cloud.cfg.d/90_dpkg.cfg
datasource_list: [ NoCloud, ConfigDrive, None ]
EOF

# Update 10_vyos_current.cfg
# this config add disk_setup and mounts in cloud_init_modules, in order to mount disk in vm
# origin file: https://github.com/vyos/vyos-cloud-init/blob/current/config/cloud.cfg.d/10_vyos.cfg
yq -iy '.cloud_init_modules += ["disk_setup", "mounts"]' /etc/cloud/cloud.cfg.d/10_vyos.cfg
yq -iy '.cloud_final_modules += ["power-state-change"]' /etc/cloud/cloud.cfg.d/10_vyos.cfg

# run dpkg-reconfigure cloud-init
# ref: https://github.com/vyos/vyos-cloud-init/blob/11d4c4719c45807c9fa4449479b359402f9c054b/tests/unittests/config/test_apt_source_v3.py#L1423
dpkg-reconfigure -f noninteractive cloud-init

# Add source-directory to the /etc/network/interfaces
# https://github.com/vyos/vyos-cloud-init/blob/current/cloudinit/config/cc_vyos_ifupdown.py#L31
cat <<EOF >>/etc/network/interfaces
source-directory /etc/network/interfaces.d
EOF

# https://serverfault.com/questions/1145467/missing-binaries-hv-get-dhcp-info-and-hv-get-dns-info
mkdir /usr/libexec/hypervkvpd
# https://git.centos.org/rpms/hyperv-daemons/blob/c8/f/SPECS/hyperv-daemons.spec#_227
/usr/bin/install -p -m 0755 /mnt/hv_get_dhcp_info.sh /usr/libexec/hypervkvpd/hv_get_dhcp_info
/usr/bin/install -p -m 0755 /mnt/hv_get_dns_info.sh /usr/libexec/hypervkvpd/hv_get_dns_info