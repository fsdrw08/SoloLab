#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

set protocols bgp 64512 parameters router-id 192.168.255.1
# https://en.wikipedia.org/wiki/Autonomous_system_%28Internet%29
set protocols bgp 64512 neighbor 192.168.255.11 remote-as 64513
# set protocols bgp 64512 neighbor 192.168.255.12 remote-as 64513
# set protocols bgp 64512 neighbor 192.168.255.13 remote-as 64513

commit
save