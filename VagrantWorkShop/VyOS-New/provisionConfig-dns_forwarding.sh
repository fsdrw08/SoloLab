#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

set service dns forwarding cache-size '0'
set service dns forwarding listen-address '192.168.255.1'
set service dns forwarding allow-from '192.168.255.0/24'
set service dns forwarding name-server 223.5.5.5
set service dns forwarding name-server 223.6.6.6

set system name-server 192.168.255.1

commit
save
