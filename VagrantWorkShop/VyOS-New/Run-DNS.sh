#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/nitnelave/lldap
set container network technitium_net prefix 172.30.0.0/16
set container name technitium image technitium/dns-server
set container name technitium network technitium_net address 172.30.0.10
# set container name technitium cap-add net-bind-service
# set container name technitium port DNS source 53
# set container name technitium port DNS destination 53
# set container name technitium port DOT source 853
# set container name technitium port DOT destination 853
# set container name technitium port DHCP source 67
# set container name technitium port DHCP destination 67
# set container name technitium port technitium_web source 5380
# set container name technitium port technitium_web destination 5380
# set container name technitium environment 'TZ' value 'Asia/Shanghai'
# set container name technitium environment 'DNS_SERVER_DOMAIN' value 'sololab'
# set container name technitium environment 'DNS_SERVER_LOG_USING_LOCAL_TIME' value 'true'
# set container name technitium volume 'technitium_data' source '/home/vagrant/technitium_data'
# set container name technitium volume 'technitium_data' destination '/etc/dns/config'


# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
# set nat source rule 30 description 'technitium forward'
# set nat source rule 30 outbound-interface 'eth0'
# set nat source rule 30 source address 172.30.0.0/16
# set nat source rule 30 translation address masquerade

# set nat destination rule 30 description 'technitium web forward'
# set nat destination rule 30 inbound-interface 'eth1'
# set nat destination rule 30 protocol 'tcp_udp'
# set nat destination rule 30 destination port 5380
# set nat destination rule 30 source address 192.168.255.0/24
# set nat destination rule 30 translation address 172.30.0.10

commit
save

# show log container lldap 
# podman run technitium/dns-server --net cni-podman