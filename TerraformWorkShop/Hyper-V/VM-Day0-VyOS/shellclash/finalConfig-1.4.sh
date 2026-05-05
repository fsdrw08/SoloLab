#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://minbx.com/tipslab/27/
# https://forum.tinyserve.com/d/6-build-a-gateway-dns-server-with-v2ray-on-vyos-to-across-gfw
set nat destination rule 10 description 'CLASH FORWARD'
set nat destination rule 10 inbound-interface name 'eth1'
set nat destination rule 10 protocol 'tcp_udp'
set nat destination rule 10 destination port 80,443
set nat destination rule 10 source address 192.168.255.0/24
set nat destination rule 10 translation address 192.168.255.1
set nat destination rule 10 translation port 7892

commit
save
