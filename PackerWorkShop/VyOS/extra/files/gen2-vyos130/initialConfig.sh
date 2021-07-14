#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure
set service ssh port 22

set system login user vagrant authentication plaintext-password vagrant
set system login user vagrant authentication public-keys 'vagrant' key "AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=="
set system login user vagrant authentication public-keys 'vagrant' type ssh-rsa

set interfaces ethernet eth0 address 192.168.255.1/24
set interfaces ethernet eth0 description LAN

# set interfaces ethernet eth1 address dhcp
# set interfaces ethernet eth1 description WAN

set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 start 192.168.255.10
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 stop 192.168.255.250
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 dns-server 192.168.255.1
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 default-router 192.168.255.1
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 domain-name vyos

# set service dns forwarding listen-address '192.168.255.1'
# set service dns forwarding allow-from '192.168.255.0/24'
# set service dns forwarding name-server 223.5.5.5
# set service dns forwarding name-server 223.6.6.6

# set system name-server 192.168.255.1

# set nat source rule 100 source address '192.168.255.1'
# set nat source rule 100 outbound-interface 'eth1'
# set nat source rule 100 translation address masquerade

commit
save
