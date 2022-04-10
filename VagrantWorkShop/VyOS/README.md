to install clash and config as transparnt proxy into the VYOS box, run following command in the vm:

`sudo su`
`bash -c "$(cat /tmp/install.sh)"  && source /etc/profile &> /dev/null`

#or

`mkdir ~/.local/share -p`
`bash -c "$(cat ~/install-clash.sh)"  && source /etc/profile &> /dev/null`
`source ~/.bashrc`
`clash`
`bash ~/finalConfig.sh`

settings for reuse
```
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