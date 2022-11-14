#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
mkdir -p /home/vagrant/samba/{config,share}

if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/samba-in-kubernetes/samba-container/tree/master
set container network samba_net prefix 172.30.0.0/16
set container name samba image quay.io/samba.org/samba-server:latest
set container name samba network samba_net address 172.30.0.10
set container name samba port smb source 445
set container name samba port smb destination 445
# set container name samba cap-add sys-admin
set container name samba environment 'TZ' value 'Asia/Shanghai'
set container name samba environment 'SAMBACC_CONFIG' value '/etc/samba-container/config.json'
set container name samba volume 'samba_config' source '/home/vagrant/samba/config'
set container name samba volume 'samba_config' destination '/etc/samba-container'
set container name samba volume 'samba_share' source '/home/vagrant/samba/share'
set container name samba volume 'samba_share' destination '/share'


# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat destination rule 30 description 'samba forward'
set nat destination rule 30 inbound-interface 'eth1'
set nat destination rule 30 protocol 'tcp_udp'
set nat destination rule 30 destination port 445
set nat destination rule 30 source address 192.168.255.0/24
set nat destination rule 30 translation address 172.30.0.10



commit
save

# show log container samba 