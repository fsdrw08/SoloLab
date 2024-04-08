#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi
source /opt/vyatta/etc/functions/script-template
run add container image quay.io/cockpit/ws:latest
configure
# Container networks
set container network containers prefix '172.16.0.0/24'
# consul
set container name cockpitws network containers address 172.16.0.30
set container name cockpitws image quay.io/cockpit/ws:latest
set container name cockpitws port cockpitws_http source 9090
set container name cockpitws port cockpitws_http destination 9090
set container name cockpitws environment 'TZ' value 'Asia/Shanghai'
# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat destination rule 20 description 'cockpitws forward'
set nat destination rule 20 inbound-interface name 'eth1'
set nat destination rule 20 protocol 'tcp_udp'
set nat destination rule 20 destination port 9090
set nat destination rule 20 source address 192.168.255.0/24
set nat destination rule 20 translation address 172.16.0.10

commit
save