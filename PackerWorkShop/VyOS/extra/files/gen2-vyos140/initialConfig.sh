#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure
# set service ssh port 22

# set system login user vagrant authentication plaintext-password vagrant
# set system login user vagrant authentication public-keys 'vagrant' key "AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=="
# set system login user vagrant authentication public-keys 'vagrant' type ssh-rsa

# set interfaces ethernet eth0 address dhcp
# set interfaces ethernet eth0 description WAN

set container name pihole image pihole/pihole:latest
set container name pihole allow-host-networks
set container name pihole port DNS source 53
set container name pihole port DNS destination 53
set container name pihole port DHCP source 67
set container name pihole port DHCP destination 67
set container name pihole port http source 80
set container name pihole port http destination 80
set container name pihole volume 'pihole' source /config/pihole/
set container name pihole volume 'pihole' destination /etc/pihole/
set container name pihole volume 'dnsmasq.d' source /config/dnsmasq.d/
set container name pihole volume 'dnsmasq.d' destination /etc/dnsmasq.d/
mkdir /config/pihole/
mkdir /config/dnsmasq.d/

commit
save