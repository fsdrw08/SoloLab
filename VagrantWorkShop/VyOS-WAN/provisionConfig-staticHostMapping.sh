#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/system/host-name.html
set system static-host-mapping host-name infra.sololab inet 192.168.255.10
set system static-host-mapping host-name infra.sololab alias infra.sololab

commit
save