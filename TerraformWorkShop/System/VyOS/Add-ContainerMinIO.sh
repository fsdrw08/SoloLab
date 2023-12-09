#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi
source /opt/vyatta/etc/functions/script-template
run add container image docker.io/bitnami/minio:latest
sudo mkdir -p /mnt/data/bitnami/minio/data
sudo chmod 777 /mnt/data/bitnami/minio/data
configure
# Container networks
set container network containers prefix '172.16.0.0/24'
# consul
set container name minio network containers address 172.16.0.40
set container name minio image docker.io/bitnami/minio:latest
set container name minio memory 1024
set container name minio port minio_http source 9000
set container name minio port minio_http destination 9000
set container name minio port minio_console source 9001
set container name minio port minio_console destination 9001
set container name minio environment 'TZ' value 'Asia/Shanghai'
# https://github.com/bitnami/containers/tree/main/bitnami/minio#persisting-your-database
set container name minio volume 'minio_data' source '/mnt/data/bitnami/minio/data'
set container name minio volume 'minio_data' destination '/bitnami/minio/data'
# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat destination rule 40 description 'minio http forward'
set nat destination rule 40 inbound-interface 'eth1'
set nat destination rule 40 protocol 'tcp_udp'
set nat destination rule 40 destination port 9000
set nat destination rule 40 source address 192.168.255.0/24
set nat destination rule 40 translation address 172.16.0.40

set nat destination rule 41 description 'minio console forward'
set nat destination rule 41 inbound-interface 'eth1'
set nat destination rule 41 protocol 'tcp_udp'
set nat destination rule 41 destination port 9001
set nat destination rule 41 source address 192.168.255.0/24
set nat destination rule 41 translation address 172.16.0.40
              
commit
save