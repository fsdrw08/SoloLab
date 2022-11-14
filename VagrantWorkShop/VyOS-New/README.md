### To install clash and config as transparnt proxy into the VYOS box
run following command in the vm:
```shell
mkdir ~/.local/share -p
bash -c "$(cat ~/install-clash.sh)"  && source /etc/profile &> /dev/null
# or 
export url='http://shellclash.ga/' && wget -q -O /tmp/install.sh $url/install.sh  && bash -c "$(cat /tmp/install.sh)" && source /etc/profile &> /dev/null
```
then: 
select 当前用户目录, after finish, source the clash, 
```shell
source ~/.bashrc
# run clash
clash
# select 主路由
# after finish, 切换安装源
```
finially, 
```
bash ~/finalConfig.sh
```

### run lldap and samba in vyos (1.4+)
1. ensure `Run-LLDAP.sh`, `Run-Samba2.sh` and `samba` folder are exist in /home/vagrant folder
```shell
vagrant@vyos:~$ ls /home/vagrant -l
total 44
-rw-r--r-- 1 vagrant     users   679 Nov  6 21:21 finalConfig.sh
-rw-r--r-- 1 vagrant     users 11561 Nov  6 21:21 install-clash.sh
drwxr-xr-x 2 radius_user  1000  4096 Nov 14 10:17 lldap_data
-rw-r--r-- 1 vagrant     users  1732 Nov  6 21:21 Run-LLDAP.sh
-rw-r--r-- 1 vagrant     users  1740 Nov 14 02:01 Run-Samba2.sh
drwxr-xr-x 5 vagrant     users  4096 Nov 14 01:52 samba
drwx------ 2 root        root   4096 Nov  6 13:25 vfs-containers
drwx------ 2 root        root   4096 Nov 13 12:57 vfs-layers
drwx------ 2 root        root   4096 Nov  6 13:25 vfs-locks
```
2. Add container and run containers
```shell
bash Add-Containers.sh
bash Run-LLDAP.sh
bash Run-Samba2.sh
```


to config bgp, run below command in git-bash
```shell
ssh vyos < <location_of_this_repo>/VagrantWorkShop/VyOS-WAN/provisionConfig-BGP.sh
```


then re-config the host ip
settings for reuse
```shell
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 start 192.168.255.10
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 range 0 stop 192.168.255.250
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 dns-server 192.168.255.1
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 default-router 192.168.255.1
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 domain-name lab

set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 static-mapping DNS mac-address '00:00:BA:BE:FA:CE'
set service dhcp-server shared-network-name LAN subnet 192.168.255.0/24 static-mapping DNS ip-address '192.168.255.2'


set service dhcp-relay interface eth0
set service dhcp-relay server 192.168.255.2
set service dhcp-relay relay-options relay-agents-packets discard

del service dhcp-server
```

config dynamic dns update to powerdns from vyos dhcp server (dhcpd)
ref:
    https://forum.vyos.io/t/how-to-configure-dhcp-server-to-update-dns-zone/6231/6
```shell
config
set service dhcp-server dynamic-dns-update
set service dhcp-server shared-network-name LAN shared-network-parameters "key dhcp-key { algorithm hmac-sha256; secret FrumijkFJtKANXpQ/ast8uZAtEa0/OO/0qwLIjPesqCe2a0WE05v1Ax4NBxP2EZI2+j1cYq/99hbwi3epUldWg==; };"

set service dhcp-server shared-network-name LAN shared-network-parameters "ddns-domainname &quot;sololab.&quot;;"

set service dhcp-server shared-network-name LAN shared-network-parameters "ddns-rev-domainname &quot;in-addr.arpa.&quot;;"

set service dhcp-server shared-network-name LAN shared-network-parameters "zone sololab. { primary 192.168.255.21; key dhcp-key; }"

set service dhcp-server shared-network-name LAN shared-network-parameters "zone 255.168.192.in-addr.arpa. { primary 192.168.255.21; key dhcp-key; }"
```

podman run 