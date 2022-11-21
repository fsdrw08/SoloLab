#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
# https://holdmybeersecurity.com/2020/07/09/install-setup-vault-for-pki-nginx-docker-becoming-your-own-ca/
su vagrant -c "mkdir -p /home/vagrant/consul/{config,data} && chmod -R 777 /home/vagrant/consul/data/"

if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/bitnami/containers/tree/main/bitnami/consul
set container network consul_net prefix 172.40.0.0/16
set container name consul image docker.io/bitnami/consul:latest
set container name consul network consul_net address 172.40.0.10

# https://github.com/bitnami/containers/tree/main/bitnami/consul#using-custom-hashicorp-consul-configuration-files
set container name consul port consul_rpc source 8300
set container name consul port consul_rpc destination 8300
set container name consul port consul_serf source 8301
set container name consul port consul_serf destination 8301
set container name consul port consul_http source 8500
set container name consul port consul_http destination 8500
set container name consul port consul_dns source 8600
set container name consul port consul_dns destination 8600
set container name consul environment 'TZ' value 'Asia/Shanghai'
# http://m.lanhusoft.com/Article/748.html
# https://github.com/bitnami/containers/blob/main/bitnami/consul/1/debian-11/rootfs/opt/bitnami/scripts/consul/run.sh
set container name consul environment 'CONSUL_BIND_ADDR' value '127.0.0.1'

# https://github.com/bitnami/containers/tree/main/bitnami/consul#using-custom-hashicorp-consul-configuration-files
# set container name consul volume 'consul_config' source '/home/vagrant/consul/config'
# set container name consul volume 'consul_config' destination '/opt/bitnami/consul/conf'

# https://github.com/bitnami/containers/tree/main/bitnami/consul#persisting-your-application
set container name consul volume 'consul_data' source '/home/vagrant/consul/data'
set container name consul volume 'consul_data' destination '/bitnami'


# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat destination rule 40 description 'consul forward'
set nat destination rule 40 inbound-interface 'eth1'
set nat destination rule 40 protocol 'tcp_udp'
set nat destination rule 40 destination port 8500
set nat destination rule 40 source address 192.168.255.0/24
set nat destination rule 40 translation address 172.40.0.10



commit
save

# show log container consul 
# # sudo podman run -d --name consul --network=consul_net --port 8500:8500 -v /home/vagrant/consul/data:/bitnami docker.io/bitnami/consul:latest consul agent -server -bind=127.0.0.1 -data-dir /bitnami
# sudo podman run --name consul --network=consul_net -p 8500:8500 -v /home/vagrant/consul/data:/bitnami \
# -e CONSUL_BIND_INTERFACE=eth0 -e CONSUL_BIND_ADDR=127.0.0.1 docker.io/bitnami/consul:latest 
# -e CONSUL_CLIENT_LAN_ADDRESS=127.0.0.1 docker.io/bitnami/consul:latest 
# consul agent -server -data-dir /bitnami