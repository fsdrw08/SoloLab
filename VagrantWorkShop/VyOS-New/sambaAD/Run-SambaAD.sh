#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
mkdir -p /home/vagrant/sambaAD/{config,share}

if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/samba-in-kubernetes/samba-container/tree/master
set container network samba_net prefix 172.30.0.0/16
set container name sambaad image quay.io/samba.org/samba-ad-server:latest
set container name sambaad network samba_net address 172.30.0.40
# set container name sambaad port dns source 53
# set container name sambaad port dns destination 53

# set container name sambaad port epm source 135
# set container name sambaad port epm destination 135
# set container name sambaad port epm protocol tcp

# set container name sambaad port netbios-ns source 137
# set container name sambaad port netbios-ns destination 137
# set container name sambaad port netbios-ns protocol udp

# set container name sambaad port netbios-dgram source 138
# set container name sambaad port netbios-dgram destination 138
# set container name sambaad port netbios-dgram protocol udp

# set container name sambaad port netbios-session source 139
# set container name sambaad port netbios-session destination 139
# set container name sambaad port netbios-session protocol tcp

set container name sambaad port ldap source 389
set container name sambaad port ldap destination 389

# set container name sambaad port smb source 445
# set container name sambaad port smb destination 445
# set container name sambaad port smb protocol tcp

# set container name sambaad port kerberos source 464
# set container name sambaad port kerberos destination 464

set container name sambaad port ldaps source 636
set container name sambaad port ldaps destination 636

# set container name sambaad port gc source 3268
# set container name sambaad port gc destination 3268
# set container name sambaad port gc protocol tcp

# set container name sambaad port gc-ssl source 3269
# set container name sambaad port gc-ssl destination 3269
# set container name sambaad port gc-ssl protocol tcp

set container name sambaad cap-add sys-admin

set container name sambaad environment 'TZ' value 'Asia/Shanghai'
set container name sambaad environment 'SAMBACC_CONFIG' value '/etc/samba-container/config.json'
set container name sambaad volume 'sambaAD_config' source '/home/vagrant/sambaAD/config'
set container name sambaad volume 'sambaAD_config' destination '/etc/samba-container'

# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat destination rule 40 description 'sambaad forward'
set nat destination rule 40 inbound-interface 'eth1'
set nat destination rule 40 protocol 'tcp_udp'
set nat destination rule 40 destination port 389,636
set nat destination rule 40 source address 192.168.255.0/24
set nat destination rule 40 translation address 172.30.0.40



commit
save

# show log container sambaad 