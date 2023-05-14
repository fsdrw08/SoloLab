ref:
- https://github.com/juewuy/ShellClash/blob/master/README_CN.md
- https://juewuy.github.io/bdaz/

1. copy files to vyos
```powershell
$debPath = "$env:USERPROFILE\OneDrive\Software\Network\shellclash-linux\*"
scp $debPath vyos:/tmp/
```
2. install shellclash in vyos
```shell
sudo su
mkdir -p /tmp/SC_tmp && tar -zxf '/tmp/ShellClash.tar.gz' -C /tmp/SC_tmp/ && bash /tmp/SC_tmp/init.sh && source /etc/profile >/dev/null
#  2 在/usr/share目录下安装(适合Linux系统)
```
3. source shellclash
```shell
echo "alias clash=\"bash /usr/share/clash/clash.sh\"" >> ~/.bashrc
echo "export clashdir=\"/usr/share/clash\"" >> ~/.bashrc
source ~/.bashrc
# launch clash 
clash
```
4. config clash
- 1 路由设备配置局域网透明代理
- 2 clash功能设置 -> 1 切换Clash运行模式: -> 7 Nft混合：使用nft_tproxy转发
- 2 clash功能设置 -> 6 设置本机代理服务:    未开启   ————使本机流量经过clash内核
- 7 clash进阶设置 -> 8 手动指定相关端口、秘钥 -> 8 自定义本机host地址：...

5. install shellclash:
from vyos, run 
```shell
sudo su
# set proxy
export all_proxy=http://ip_address:port_number
# run shellclash install script
export url='https://gh.jwsc.eu.org/master' && bash -c "$(curl -kfsSl $url/install.sh)" && source /etc/profile &> /dev/null
#  2 在/usr/share目录下安装(适合Linux系统)

# run below command to source clash
echo "alias clash=\"bash /usr/share/clash/clash.sh\"" >> ~/.bashrc
echo "export clashdir=\"/usr/share/clash\"" >> ~/.bashrc
source ~/.bashrc

# launch and config shellclash
clash
# 1  路由设备配置局域网透明代理
# 2 clash功能设置 -> 1 切换Clash运行模式: -> 7 Nft混合：使用nft_tproxy转发
# 2 clash功能设置 -> 6 设置本机代理服务:    未开启   ————使本机流量经过clash内核
# 7 clash进阶设置 -> 8 手动指定相关端口、秘钥 -> 8 自定义本机host地址：...

# unset proxy
unset all_proxy
```

2. update nat config
```shell
bash ~/finalConfig.sh
```