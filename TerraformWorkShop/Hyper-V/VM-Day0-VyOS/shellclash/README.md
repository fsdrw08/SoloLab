ref:
- https://github.com/juewuy/ShellClash/blob/master/README_CN.md
- https://juewuy.github.io/bdaz/

1. copy files to vyos
```powershell
$debPath = "$env:USERPROFILE\OneDrive\Software\Network\shellclash-linux\1.8.0\*"
$debPath = "$env:USERPROFILE\OneDrive\Software\Network\shellclash-linux\1.9.0\*"
$debPath = "$env:USERPROFILE\OneDrive\Software\Network\shellclash-linux\1.9.1\*"
$debPath = "$env:USERPROFILE\OneDrive\Software\Network\shellclash-linux\1.9.1-pre\*"
# or 
$debPath = "$env:USERPROFILE\OneDrive - Company Ltd\Software\Network\shellclash-linux\1.9.1\*"
scp $debPath vyos:/tmp/
```
2. install shellclash in vyos
```shell
sudo su
mkdir -p /tmp/SC_tmp && tar -zxf '/tmp/ShellCrash.tar.gz' -C /tmp/SC_tmp/ && bash /tmp/SC_tmp/init.sh && source /etc/profile >/dev/null
#  2 在/usr/share目录下安装(适合Linux系统)
```
3. source shellclash
for shellcrash
```shell
echo "alias crash=\"bash /usr/share/ShellCrash/menu.sh\"" >> ~/.bashrc
echo "alias clash=\"bash /usr/share/ShellCrash/menu.sh\"" >> ~/.bashrc
echo "export CRASHDIR=\"/usr/share/ShellCrash\"" >> ~/.bashrc
source ~/.bashrc
# launch clash 
crash
```
```shell
echo "alias clash=\"bash /usr/share/clash/clash.sh\"" >> ~/.bashrc
echo "export clashdir=\"/usr/share/clash\"" >> ~/.bashrc
source ~/.bashrc
# launch clash 
clash
```
1. config clash
- 1 路由设备配置局域网透明代理 -> 是否开启公网访问Dashboard面板及socks服务？ 0 
    -> 是否导入配置文件？0 -> 立即启动clash服务？0 -> 发现可用的内核文件： /tmp/clash-linux-amd64-meta 
    是否加载？ 1
- 2 clash功能设置 -> 1 切换Clash运行模式: -> 7 Nft混合：使用nft_tproxy转发
- 2 clash功能设置 -> 6 设置本机代理服务:    未开启   ————使本机流量经过clash内核
- 7 clash进阶设置 -> 8 手动指定相关端口、秘钥 -> 8 自定义本机host地址：...

v1.8.0
- 7 clash进阶设置 ->  6 配置内置DNS服务 -> 7 禁用DNS劫持：已禁用, 2 修改Fallback_DNS: 192.168.255.1
- 7 clash进阶设置 ->  6 配置内置DNS服务 ->  4 一键配置加密DNS
-

v1.9.1
- 2 内核功能设置 -> 2 切换DNS运行模式 -> 4 DNS进阶设置 -> 7 禁用DNS劫持
- 7 内核进阶设置 ->  5 自定义端口及秘钥 -> 8 自定义本机host地址
<!-- 
1. install shellclash:
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
``` -->

5. update nat config
```shell
bash /tmp/finalConfig.sh
```