#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

set service dhcp-relay interface eth0
set service dhcp-relay server 192.168.255.2
# https://docs.vyos.io/en/equuleus/configuration/service/dhcp-relay.html#cfgcmd-set-service-dhcp-relay-relay-options-relay-agents-packet-append-discard-forward-replace
set service dhcp-relay relay-options relay-agents-packets discard

commit
save

#? set nat source rule 100 source address '192.168.255.1'
#? set nat source rule 100 outbound-interface 'eth1'
#? set nat source rule 100 translation address masquerade

# delete system name-server

# set nat destination rule 10 description 'DNS Redirect'
# set nat destination rule 10 destination port 53
# set nat destination rule 10 inbound-interface 'eth0'
# set nat destination rule 10 protocol 'tcp_udp'
# set nat destination rule 10 translation address 192.168.255.1
# set nat destination rule 10 translation port 1053

# set nat destination rule 20 description 'HTTP Redirect'
# set nat destination rule 20 destination port 80,443
# set nat destination rule 20 inbound-interface 'eth0'
# set nat destination rule 20 protocol 'tcp_udp'
# set nat destination rule 20 translation address 192.168.255.1
# set nat destination rule 20 translation port 7892

# commit
# save
