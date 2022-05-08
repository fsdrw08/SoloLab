#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://blog.kroy.io/2020/05/04/vyos-from-scratch-edition-1/#:~:text=8.8.4.4%0Acommit%0Asave-,System%20DNS,-One%20final%20step
# https://forum.tinyserve.com/d/6-build-a-gateway-dns-server-with-v2ray-on-vyos-to-across-gfw
# according to the artical above, it have not set up name-server, so we should delete name-server config after clash setup
delete system name-server

# set system domain-name vyos
# set system static-host-mapping host-name awx.ansible.vyos inet 192.168.255.11

set nat destination rule 10 description 'DNS Redirect'
set nat destination rule 10 destination port 53
set nat destination rule 10 inbound-interface 'eth0'
set nat destination rule 10 protocol 'tcp_udp'
set nat destination rule 10 translation address 192.168.255.1
set nat destination rule 10 translation port 1053

set nat destination rule 20 description 'HTTP Redirect'
set nat destination rule 20 destination port 80,443
set nat destination rule 20 inbound-interface 'eth0'
set nat destination rule 20 protocol 'tcp_udp'
set nat destination rule 20 translation address 192.168.255.1
set nat destination rule 20 translation port 7892

# set nat destination rule 30 description 'DHCP Redirect'
# set nat destination rule 30 destination port 67
# set nat destination rule 30 inbound-interface 'eth0'
# set nat destination rule 30 protocol 'udp'
# set nat destination rule 30 translation address 0.0.0.0
# set nat destination rule 30 translation port 67

# set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 static-mapping DNS mac-address '00:00:BA:BE:FA:CE'
# set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 static-mapping DNS ip-address '192.168.255.2'
# set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 dns-server 192.168.255.2

# set service dhcp-server dynamic-dns-update
# set service dhcp-server shared-network-name LAN shared-network-parameters "key rndc-key { algorithm hmac-md5; secret FYhvwsW1ZtFZqWzsMpqhbg==; };"
# set service dhcp-server shared-network-name LAN shared-network-parameters "ddns-domainname &quot;lab.&quot;;"
# set service dhcp-server shared-network-name LAN shared-network-parameters "zone lab. { primary 192.168.255.2; key rndc-key; }"

commit
save
