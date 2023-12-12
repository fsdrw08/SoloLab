#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi
source /opt/vyatta/etc/functions/script-template
run add container image quay.io/cockpit/ws:latest
configure

set nat destination rule 20 description 'consul dns'
set nat destination rule 20 destination port '53'
set nat destination rule 20 inbound-interface 'eth2'
set nat destination rule 20 protocol 'tcp_udp'
set nat destination rule 20 translation address '192.168.255.2'
set nat destination rule 20 translation port '8600'

commit
save