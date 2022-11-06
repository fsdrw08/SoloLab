#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/nitnelave/lldap
set container network alpine prefix 172.40.0.0/16
set container name alpine image library/alpine
set container name alpine network alpine

commit
save

# show log container lldap 
# podman run technitium/dns-server --net cni-podman