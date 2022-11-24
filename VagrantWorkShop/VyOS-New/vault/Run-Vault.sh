#!/bin/vbash
# Ensure that we have the correct group or we'll corrupt the configuration
# https://holdmybeersecurity.com/2020/07/09/install-setup-vault-for-pki-nginx-docker-becoming-your-own-ca/
mkdir -p /home/vagrant/vault/{config,share}

if [ "$(id -g -n)" != 'vyattacfg' ] ; then
    exec sg vyattacfg -c "/bin/vbash $(readlink -f $0) $@"
fi

source /opt/vyatta/etc/functions/script-template
configure

# https://docs.vyos.io/en/latest/configuration/container/index.html
# https://github.com/docker-library/docs/tree/master/vault
set container network vault_net prefix 172.40.0.0/16
set container name vault image docker.io/hashicorp/vault:latest
set container name vault network vault_net address 172.40.0.10
set container name vault port smb source 445
set container name vault port smb destination 445
# set container name vault cap-add sys-admin
set container name vault environment 'TZ' value 'Asia/Shanghai'
set container name vault environment 'SAMBACC_CONFIG' value '/etc/samba-container/config.json'
set container name vault volume 'vault_config' source '/home/vagrant/vault/config'
set container name vault volume 'vault_config' destination '/etc/vault-container'
set container name vault volume 'vault_share' source '/home/vagrant/vault/share'
set container name vault volume 'vault_share' destination '/share'


# https://gist.github.com/peterkeen/97c566131af6f085628b5e4f1c4a8e1b
# https://www.reddit.com/r/vyos/comments/vkfuoo/dns_container_vyos/
set nat destination rule 30 description 'vault forward'
set nat destination rule 30 inbound-interface 'eth1'
set nat destination rule 30 protocol 'tcp_udp'
set nat destination rule 30 destination port 445
set nat destination rule 30 source address 192.168.255.0/24
set nat destination rule 30 translation address 172.30.0.10



commit
save

# show log container vault 