#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
set container network nfs-net prefix 172.20.0.0/16
set container name nfs image gists/nfs-server
set container name nfs network nfs-net
set container name nfs port NFS source 2049
set container name nfs port NFS destination 2049
set container name nfs cap-add sys-admin
set container name nfs cap-add setpcap
set container name nfs cap-add net-admin
set container name nfs environment 'TZ' value 'Asia/Shanghai'
set container name nfs volume 'NFS-Share' source '/home/vagrant/nfs-share'
set container name nfs volume 'NFS-Share' destination 'nfs-share'

# set container name alp01 image 'alpine'
# set container name alp01 allow-host-networks

commit
save