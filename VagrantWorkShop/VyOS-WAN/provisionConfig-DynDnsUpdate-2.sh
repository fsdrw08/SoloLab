#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://forum.vyos.io/t/how-to-configure-dhcp-server-to-update-dns-zone/6231/6
# https://gist.github.com/helushune/1abc37b0e3c90f01300e7ce4c40fe6ab
set service dhcp-server dynamic-dns-update
set service dhcp-server shared-network-name LAN shared-network-parameters "key sololab { algorithm hmac-sha256; secret CdfWki3NHLLizpZ9nvK/wqojh//xENcu8zX8aYfcOds=; };"

set service dhcp-server shared-network-name LAN shared-network-parameters "ddns-domainname &quot;infra.sololab.&quot;;"

# set service dhcp-server shared-network-name LAN shared-network-parameters "ddns-rev-domainname &quot;in-addr.arpa.&quot;;"

set service dhcp-server shared-network-name LAN shared-network-parameters "zone infra.sololab. { primary 192.168.255.32; key sololab; }"

# set service dhcp-server shared-network-name LAN shared-network-parameters "zone 255.168.192.in-addr.arpa. { primary 192.168.255.31; key dhcp-key; }"

commit
save
