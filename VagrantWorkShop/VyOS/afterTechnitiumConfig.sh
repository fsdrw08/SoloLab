#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

del service dhcp-server
set service dhcp-relay interface eth0
set service dhcp-relay server 192.168.255.3
set service dhcp-relay relay-options relay-agents-packets discard

commit
save