#!/bin/bash
# ref: https://github.com/vyos/vyos-vm-images/blob/07825901d1ebb483ac6edc39e0a4c224fad82638/roles/install-cloud-init/tasks/main.yml
# Put debian.list
touch /etc/apt/sources.list.d/debian.list
cat <<EOF >>/etc/apt/sources.list.d/debian.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
deb http://dev.packages.vyos.net/repositories/equuleus equuleus main
EOF

# apt-get update
apt-get update

# Install cloud-init
apt-get install -t equuleus -y --force-yes cloud-init cloud-utils ifupdown jq nfs-ganesha nfs-ganesha-vfs

# stop and disable nfs-ganesha
systemctl disable nfs-ganesha

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

# Update 10_vyos.cfg
cp /mnt/10_vyos.cfg /etc/cloud/cloud.cfg.d/10_vyos.cfg

# run dpkg-reconfigure cloud-init
dpkg-reconfigure -f noninteractive cloud-init

# Add source-directory to the /etc/network/interfaces
cat <<EOF >>/etc/network/interfaces
source-directory /etc/network/interfaces.d
EOF
