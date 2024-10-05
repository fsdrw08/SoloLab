### add vbox
```powershell
vagrant box add VYOS14x-G2 "C:\Users\Public\Downloads\vbox\packer-vyos14x-hv-g2.box"
```

Set internal switch net adapter profile to private
```powershell
sudo Set-NetConnectionProfile -InterfaceAlias *Internal* -NetworkCategory Private
```

config net adapter interface metric before `vagrant up`

to install clash and config as transparnt proxy into the VYOS box, run following command in the vm:

```shell
sudo su
bash -c "$(cat /tmp/install.sh)"  && source /etc/profile &> /dev/null
```
or
```shell
# mkdir ~/.local/share -p
# bash -c "$(cat ~/install-clash.sh)"  && source /etc/profile &> /dev/null
sudo su
bash -c "$(cat /home/vagrant/install-clash.sh)"  && source /etc/profile &> /dev/null
#  2 在/usr/share目录下安装(适合Linux系统)
echo "alias clash=\"bash /usr/share/clash/clash.sh\"" >> ~/.bashrc
echo "export clashdir=\"/usr/share/clash\"" >> ~/.bashrc
source ~/.bashrc
clash
# 1  路由设备配置局域网透明代理
# ...
# 2 clash功能设置 -> 1 切换Clash运行模式: -> 2 混合模式： Redir转发TCP，Tun转发UDP / 7 Nft混合：使用nft_tproxy转发
# 2 clash功能设置 ->  6 设置本机代理服务:    未开启   ————使本机流量经过clash内核
TCP&UDP
bash ~/finalConfig.sh
# 当前用户目录下安装(适合非root用户)
```

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