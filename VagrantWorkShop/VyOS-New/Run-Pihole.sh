#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

mkdir -p /home/vagrant/pihole_data/{etc-pihole,etc-dnsmasq.d}
add container image docker.io/pihole/pihole:latest

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/nitnelave/lldap
set container network pihole_net prefix 172.30.0.0/16
set container name pihole image pihole/pihole:latest
set container name pihole network pihole_net address 172.30.0.10
# set container name pihole cap-add net-admin
# set container name pihole cap-add net-bind-service
# set container name pihole port DNS source 53
# set container name pihole port DNS destination 53
# set container name pihole port DHCP source 67
# set container name pihole port DHCP destination 67
set container name pihole port dns_web source 5380
set container name pihole port dns_web destination 5380
set container name pihole environment TZ value 'Asia/Shanghai'
set container name pihole environment PIHOLE_DNS_ value '223.5.5.5,223.6.6.6'
set container name pihole environment WEBPASSWORD value 'password'
set container name pihole environment WEB_PORT value '5380'
set container name pihole volume 'etc-pihole' source '/home/vagrant/pihole_data/etc-pihole'
set container name pihole volume 'etc-pihole' destination '/etc/pihole'
set container name pihole volume 'etc-dnsmasq' source '/home/vagrant/pihole_data/etc-dnsmasq.d'
set container name pihole volume 'etc-dnsmasq' destination '/etc/dnsmasq.d'


# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat source rule 30 outbound-interface eth0
set nat source rule 30 source address 172.30.0.0/16
set nat source rule 30 translation address masquerade


set nat destination rule 30 description 'pihole web forward'
set nat destination rule 30 inbound-interface 'eth1'
set nat destination rule 30 protocol 'tcp_udp'
set nat destination rule 30 destination port 5380
set nat destination rule 30 source address 192.168.255.0/24
set nat destination rule 30 translation address 172.30.0.10
set nat destination rule 30 translation port 80

commit
save

# show log container lldap 