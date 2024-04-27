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

set container name cockroach image docker.io/cockroachdb/cockroach:v23.2.4
set container name cockroach port cockroach_http listen-address '192.168.255.1'
set container name cockroach port cockroach_http source '5443'
set container name cockroach port cockroach_http destination '5443'
set container name cockroach port cockroach_db listen-address '192.168.255.1'
set container name cockroach port cockroach_db source '5432'
set container name cockroach port cockroach_db destination '5432'
set container name cockroach environment 'TZ' value 'Asia/Shanghai'
set container name cockroach volume cockroach_cert source '/etc/cockroach/certs'
set container name cockroach volume cockroach_cert destination '/certs'
set container name cockroach volume cockroach_cert mode 'ro'
set container name cockroach volume cockroach_data source '/mnt/data/cockroach'
set container name cockroach volume cockroach_data destination '/cockroach/cockroach-data'
set container name cockroach arguments 'start-single-node --sql-addr=:5432 --http-addr=:5443 --certs-dir=/certs --accept-sql-without-tls'


commit
save