to install clash and config as transparnt proxy into the VYOS box, run following command in the vm:

`sudo su`
`bash -c "$(cat /tmp/install.sh)"  && source /etc/profile &> /dev/null`

or

```shell
mkdir ~/.local/share -p
bash -c "$(cat ~/install-clash.sh)"  && source /etc/profile &> /dev/null
# or 
export url='http://shellclash.ga/' && wget -q -O /tmp/install.sh $url/install.sh  && bash -c "$(cat /tmp/install.sh)" && source /etc/profile &> /dev/null
# select 当前用户目录
source ~/.bashrc
clash
# select 主路由
bash ~/finalConfig.sh
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