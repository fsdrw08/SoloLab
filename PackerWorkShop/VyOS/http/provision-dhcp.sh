#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure
set interfaces ethernet eth0 address dhcp
set interfaces ethernet eth0 description WAN

set system name-server 119.29.29.29

commit
set interfaces ethernet eth0 disable
commit
delete interfaces ethernet eth0 disable
commit
save
