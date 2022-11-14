#!/bin/vbash
mkdir -p /home/vagrant/lldap_data
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi


source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/nitnelave/lldap
set container network lldap_net prefix 172.20.0.0/16
set container name lldap image nitnelave/lldap
set container name lldap network lldap_net address 172.20.0.3
set container name lldap port ldap source 3890
set container name lldap port ldap destination 3890
set container name lldap port lldap_web source 17170
set container name lldap port lldap_web destination 17170
set container name lldap environment 'TZ' value 'Asia/Shanghai'
set container name lldap environment 'LLDAP_JWT_SECRET' value 'REPLACE_WITH_RANDOM'
set container name lldap environment 'LLDAP_LDAP_USER_PASS' value 'password'
set container name lldap environment 'LLDAP_LDAP_BASE_DN' value 'dc=example,dc=com'
set container name lldap volume 'lldap_data' source '/home/vagrant/lldap_data'
set container name lldap volume 'lldap_data' destination '/data'


# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat destination rule 20 description 'LLDAP FORWARD'
set nat destination rule 20 inbound-interface 'eth1'
set nat destination rule 20 protocol 'tcp_udp'
set nat destination rule 20 destination port 3890,17170
set nat destination rule 20 source address 192.168.255.0/24
set nat destination rule 20 translation address 172.20.0.3



commit
save

# show log container lldap 